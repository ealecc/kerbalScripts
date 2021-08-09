parameter targetInclination is 90.
parameter targetAltitude is 80.
set targetAltitude to targetAltitude*1000.

clearScreen.
print "Launching in".
countdown(5).

// initialize throttle
set mythrottle to 1.0.
lock throttle to mythrottle.

// initialize steering
set mysteer to heading(targetInclination, 90).
lock steering to mysteer.

// begin staging
controlStage().

ascent(targetInclination, targetAltitude).

until

print"Resuming manual control in".
countdown(5).

//----------------------------------------------------------------------

// counts down from n to 0, printing to terminal
function countdown
{
    parameter n.
    until n = 0
    {
        print n.
        set n to n-1.
        wait 1.
    }.
    return.
}

// stage if thrust is zero
function controlStage
{
    when maxthrust=0 then {
        stage.
        preserve.
    }.
}

function ascent
{
    parameter inc is 90.
    parameter alt is 80000.

    lock mysteer to heading(inc, (90 - (45 * altitude / 10000))).
    when altitude > 10000 then lock mysteer to heading(inc, 45).
    when altitude > 30000 then lock mysteer to prograde.

    set throttlePID to pidLoop(
        0.05,
        0.005,
        0.005,
        0,
        1
    ).

    // reduce target time as apoapsis approaches target altitude
    set ADJUST to 200.
    lock targetETA to (ADJUST - (ADJUST * apoapsis / alt)).

    until periapsis >= alt
    {
        set throttlePID:setpoint to targetETA.
        set mythrottle to throttlePID:update(time:seconds, eta:apoapsis).
    }
}