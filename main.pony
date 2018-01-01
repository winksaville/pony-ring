actor Node
  let _start: U64
  let _ring_id: U32
  let _id: U32
  let _env: Env
  var _next: (Node | None)

  new create(start: U64, ring_id: U32, id: U32, env: Env,
    neighbor: (Node | None) = None)
  =>
    //Dbg.println(_start, "Node" + _ring_id.string() + ":" + _id.string() + ".create:+")
    _start = start
    _ring_id = ring_id
    _id = id
    _env = env
    _next = neighbor
    Dbg.println(_start, "Node" + _ring_id.string() + ":" + _id.string() + ".create:-")

  be set(neighbor: Node) =>
    _next = neighbor

  be pass(i: USize) =>
    if i > 0 then
      match _next
      | let n: Node =>
        n.pass(i - 1)
      end
    else
      Dbg.println(_start, "Node" + _ring_id.string() + ":" + _id.string()
        + ".pass:- DONE i=" + i.string())
      None
    end

  fun _final() =>
    Dbg.println(_start, "Node" + _ring_id.string() + ":" + _id.string() + "._final")

actor Main
  var _ring_size: U32 = 3
  var _ring_count: U32 = 1
  var _ring_heads: Array[Node tag]
  var _pass: USize = 10
  var _env: Env
  let _now: U64

  new create(env: Env) =>
    _env = env
    _ring_heads = Array[Node tag]()
    _now = Dbg.nanos()

    try
      parse_args()?
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
      | "--ring_size" =>
        _ring_size = value.u32()?
      | "--ring_count" =>
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
      Dbg.println(_now, "setup_ring: " + j.string())
      let first = Node(_now, j, 1, _env)
      _ring_heads.push(first)
      var next = first

      var k: U32 = 1
      while k < _ring_size do
        let current = Node(_now, j, k + 1, _env, next)
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
    for head in _ring_heads.values() do
      head.pass(_pass)
    end
    Dbg.println(_now, "start:-")

  fun _final() =>
    Dbg.println(_now, "Main._final  #!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#")
