interface CompleteNotification
  be complete(id: U32 val)

actor Node
  let _start_time: U64
  let _ring_id: U32
  let _id: U32
  let _env: Env
  let _master: CompleteNotification tag
  var _next: (Node | None)
  var _msg_count: U64 = 0

  new create(master: CompleteNotification tag, start_time: U64, ring_id: U32, id: U32, env: Env,
    neighbor: (Node | None) = None)
  =>
    //Dbg.println(_start_time, "Node" + _ring_id.string() + ":" + _id.string() + ".create:+")
    _master = consume master
    _start_time = start_time
    _ring_id = ring_id
    _id = id
    _env = env
    _next = neighbor
    //Dbg.println(_start_time, "Node" + _ring_id.string() + ":" + _id.string() + ".create:-")

  be set(neighbor: Node) =>
    _next = neighbor

  be pass(i: USize) =>
    _msg_count = _msg_count + 1
    //Dbg.println(_start_time, "Node" + _ring_id.string() + ":" + _id.string()
    //  + ".pass:+ pass i=" + i.string() + " msg_count=" + _msg_count.string())
    if i > 1 then
      match _next
      | let n: Node =>
        n.pass(i - 1)
        //Dbg.println(_start_time, "Node" + _ring_id.string() + ":" + _id.string()
        //  + ".pass:- pass i=" + i.string() + " msg_count=" + _msg_count.string())
      end
    else
      //Dbg.println(_start_time, "Node" + _ring_id.string() + ":" + _id.string()
      //  + ".pass:- DONE pass i=" + i.string() + " msg_count=" + _msg_count.string())
      _master.complete(_id)
    end

  fun _final() =>
    //Dbg.println(_start_time, "Node" + _ring_id.string() + ":" + _id.string() + "._final")
    None

actor Main is CompleteNotification
  var _ring_size: U32 = 3
  var _ring_count: U32 = 1
  var _ring_heads: Array[Node tag] = Array[Node tag]()
  var _pass: USize = 10
  var _env: Env
  var _complete_count: U32 = 0
  let _now: U64

  new create(env: Env) =>
    _env = env
    _now = Dbg.nanos()

    try
      parse_args()?
      _ring_heads = Array[Node tag](_ring_count.usize())
      setup_ring()
      start()
    else
      usage()
    end

  fun ref parse_args() ? =>
    var i: USize = 1

    while i < _env.args.size() do
      // Every option has an argument.
      var option = _env.args(i)?
      var value = _env.args(i + 1)?
      i = i + 2

      match option
      | "--size" =>
        _ring_size = value.u32()?
      | "--count" =>
        _ring_count = value.u32()?
      | "--pass" =>
        _pass = value.usize()?
      else
        error
      end
    end

  fun ref setup_ring() =>
    Dbg.println(_now, "setup_ring:+")
    var j: U32 = 0
    while j < _ring_count do
      //Dbg.println(_now, "setup_ring: " + j.string())
      let first = Node(this, _now, j, 0, _env)
      _ring_heads.push(first)
      var next = first

      var k: U32 = 1
      while k < _ring_size do
        let current = Node(this, _now, j, k, _env, next)
        next = current
        k = k + 1
      end

      first.set(next)
      j = j + 1
    end
    Dbg.println(_now, "setup_ring:-")

  fun usage() =>
    _env.out.print(
      """
      rings OPTIONS
        --size N number of actors in each ring
        --count N number of rings
        --pass N number of messages to pass around each ring
      """
      )

  be start() =>
    Dbg.println(_now, "start:+")
    if (_pass >= 1) then
      for head in _ring_heads.values() do
        head.pass(_pass)
      end
    end
    Dbg.println(_now, "start:-")

  be complete(id: U32 val) =>
    //Dbg.println(_now, "complete:+ " + id.string())
    _complete_count = _complete_count + 1
    if (_complete_count >= _ring_count) then
      Dbg.println(_now, "complete: DONE")
    end
    //Dbg.println(_now, "complete:- " + id.string())

  fun _final() =>
    Dbg.println(_now, "Main._final  #!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#")
