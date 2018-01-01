// From ponyc/packages/debug/ and ponyc/packages/time as I couldn't use
// either of these in finalizers.
use @clock_gettime[I32](clock: U32, ts: Pointer[(I64, I64)])

primitive _ClockMonotonic
  fun apply(): U32 =>
    ifdef linux then
      1
    elseif bsd then
      4
    else
      compile_error "no clock_gettime monotonic clock"
    end

class Dbg
  fun nanos(): U64 =>
    """
    Monotonic unadjusted nanoseconds.
    """
    var ts: (I64, I64) = (0, 0)
    @clock_gettime(_ClockMonotonic.apply(), addressof ts)
    ((ts._1 * 1000000000) + ts._2).u64()

  fun println(start: U64, s: String) =>
    let duration = nanos() - start
    @fprintf[I32](@pony_os_stdout[Pointer[U8]](), "%s: %s\n".cstring(),
      duration.string().cstring(), s.cstring())
