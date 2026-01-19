class AM_Utils
{
	static clearscope double Lerp(double from, double to, double frac)
	{
		return (from * (1.0 - frac)) + (to * frac);
	}

	static clearscope bool IsVoodooDoll(PlayerPawn mo) 
	{
		return !mo.player || !mo.player.mo || mo.player.mo != mo;
	}

	static clearscope bool IsInFirstPerson(Actor mo)
	{
		return mo && mo.player && 
			mo.player.mo && 
			mo.player.mo == mo && 
			mo.player == players[consoleplayer] && 
			mo.player.camera == mo && 
			!(mo.player.cheats & CF_CHASECAM);
	}
	
	static clearscope double LinearMap(double val, double source_min, double source_max, double out_min, double out_max, bool clamp_result = false) 
	{
		double sourceDiff = source_max - source_min;
		if (sourceDiff == 0)
		{
			return 0;
		}
		double d = (val - source_min) * (out_max - out_min) / sourceDiff + out_min;
		if (clamp_result)
		{
			d = Clamp(d, min(out_max, out_min), max(out_max, out_min));
		}
		return d;
	}

	static clearscope double NormalizeRange(double val, double start, double end)
	{
		if (start == end) return start;

		double truemax = max(start, end);
		double truemin = min(start, end);
		double range = truemax - truemin;
		double norm = val - range * floor((val - truemin) / range);
		if (start > end)
		{
			norm = truemax - (norm - start);
		}
		return norm;
	}

	static clearscope double SinePulse(double frequency = TICRATE, int time = -1, bool positive = true)
	{
		if (time < 0) time = level.mapTime;
		double pulse = sin((360.0 * time / frequency) - 90);
		if (positive)
			pulse = pulse*0.5 + 0.5; //return as 0.0-1.0
		return pulse; //return as -1.0-1.0
	}

	// rise and fall: lower = smoother, higher = more rapid
	static clearscope double CubicBezierPulse(double frequency = TICRATE, int time = -1, double startVal = 1.0, double rise = 0.2, double fall = 0.8, double endVal = 1.0)
	{
		if (time < 0) time = level.mapTime;

		// Normalize time:
		double t = (time / frequency) - floor(time / frequency);

		return (1 - t) * (1 - t) * (1 - t) * startVal + 3 * (1 - t) * (1 - t) * t * rise + 3 * (1 - t) * t * t * fall + t * t * t * endVal;
	}

	// Obtains a wall normal vector:
	static clearscope Vector2 GetLineNormal(Vector2 ppos, Line lline)
	{
		Vector2 linenormal;
		linenormal = (-lline.delta.y, lline.delta.x).Unit();
		if (!LevelLocals.PointOnLineSide(ppos, lline))
		{
			linenormal *= -1;
		}
		return linenormal;
	}

	// Obtains a normal vector from FLineTraceData
	// depending on what it hit:
	static play Vector3 GetNormalFromTrace(FLineTraceData normcheck)
	{
		Vector3 hitnormal = -normcheck.HitDir;
		if (normcheck.HitType == TRACE_HitFloor)
		{
			hitnormal = normcheck.Hit3DFloor ? -normcheck.Hit3DFloor.top.Normal : normcheck.HitSector.floorplane.Normal;
		}
		else if (normcheck.HitType == TRACE_HitCeiling)
		{
			hitnormal = normcheck.Hit3DFloor? -normcheck.Hit3DFloor.bottom.Normal : normcheck.HitSector.ceilingplane.Normal;
		}
		else if (normcheck.HitType == TRACE_HitWall && normcheck.HitLine)
		{
			hitnormal.xy = (-normcheck.HitLine.delta.y, normcheck.HitLine.delta.x).Unit();
			if (normcheck.LineSide == Line.front)
			{
				hitnormal.xy *= -1;
			}
			hitnormal.z = 0;
		}
		return hitnormal;
	}

	// Obtains a normal vector from TraceResults
	// depending on what it hit:
	static clearscope Vector3 GetNormalFromTracer(TraceResults res)
	{
		Vector3 normal = -res.HitVector;
		bool hit3DFloor = res.ffloor != null;
		switch(res.HitType)
		{
			case TRACE_HitFloor:
				normal = hit3DFloor? res.ffloor.top.normal : res.HitSector.floorplane.normal;
				break;
			case TRACE_HitCeiling:
				normal = hit3DFloor? res.ffloor.bottom.normal : res.HitSector.ceilingplane.normal;
				break;
			case TRACE_HitWall:
				normal.xy = (-res.HitLine.delta.y, res.HitLine.delta.x).Unit();
				if (res.Side == Line.front)
				{
					normal.xy *= -1;
				}
				normal.z = 0;
				break;
		}
		return normal;
	}
	
	// Converts offsets into relative offsets
	// mo: the actor to offset from
	// offset: desired relative offset as (forward/back, right/left, up/down)
	// isPosition: if TRUE, adds actor's position to the result. Set to FALSE when used for relative velocity.
	static clearscope Vector3 RelativeToGlobalCoords(actor mo, Vector3 offset, bool isPosition = true)
	{
		if (!mo)
			return (0,0,0);
		
		return RelativeToGlobalOffset(mo.pos, (mo.angle, mo.pitch, mo.roll), offset, isPosition);
	}

	// Same as above, but doesn't take an actor pointer.
	// startPos: original position to operate around
	// viewAngles: (angle, pitch, roll) of the desired actor. viewAngle/viewPitch/viewRoll can be added or used instead.
	// isPosition: if TRUE, adds startpos to the final result.
	static clearscope Vector3 RelativeToGlobalOffset(Vector3 startpos, Vector3 viewAngles, Vector3 offset, bool isPosition = true)
	{
		Quat dir = Quat.FromAngles(viewAngles.x, viewAngles.y, viewAngles.z);
		Vector3 ofs = dir * (offset.x, -offset.y, offset.z);
		if (isPosition)
		{
			return Level.Vec3offset(startpos, ofs);
		}
		return ofs;
	}
}

class AM_ValueInterpolator : Object
{
	double t_current;
	double t_minStep;
	double t_maxStep;
	double t_stepFactor;
	bool t_isDynamic;

	static AM_ValueInterpolator Create(double startval, double stepFactor, double minstep, double maxstep, bool dynamic = false)
	{
		let v = new('AM_ValueInterpolator');
		v.t_current = startval;
		v.t_stepFactor = stepFactor;
		v.t_minStep = minstep;
		v.t_maxStep = maxstep;
		v.t_isDynamic = dynamic;
		return v;
	}

	void Reset(double value)
	{
		t_current = value;
	}

	void Update(double destvalue, double delta = 1.0)
	{
		double diff = t_isDynamic? clamp(abs(destvalue - t_current) * t_stepFactor, t_minStep, t_maxStep) : t_maxStep;
		diff *= delta;
		if (t_current > destvalue)
		{
			t_current = max(destvalue, t_current - diff);
		}
		else
		{
			t_current = min(destvalue, t_current + diff);
		}
	}

	double GetValue()
	{
		return t_current;
	}
}

class AM_CollisionTracer : LineTracer
{
	static bool, Vector3, AM_CollisionTracer DetectFromTo(Vector3 start, Vector3 end, Actor source = null)
	{
		let tracer = new('AM_CollisionTracer');
		if (!tracer)
		{
			return false, (0,0,0), null;
		}

		Vector3 diff = level.Vec3Diff(start, end);
		tracer.Trace(start,
			sec: source? source.cursector : level.PointInSector(start.xy),
			direction: diff.Unit(),
			maxdist: diff.Length() + 1,
			traceFlags: TRACE_HitSky,
			wallmask: Line.ML_BLOCKEVERYTHING,
			ignore: source
		);

		let res = tracer.results;
		bool collided = res.HitType != TRACE_HitNone;
		Vector3 normal = AM_Utils.GetNormalFromTracer(res);

		return collided, normal, tracer;
	}

	static bool, Vector3, AM_CollisionTracer DetectAt(Vector3 start, Vector3 dir, Actor source = null)
	{
		let tracer = new('AM_CollisionTracer');
		if (!tracer)
		{
			return false, (0,0,0), null;
		}

		tracer.Trace(start,
			sec: source? source.cursector : level.PointInSector(start.xy),
			direction: dir.Unit(),
			maxdist: PLAYERMISSILERANGE,
			traceFlags: TRACE_HitSky,
			wallmask: Line.ML_BLOCKEVERYTHING,
			ignore: source
		);

		let res = tracer.results;
		bool collided = res.HitType != TRACE_HitNone;
		Vector3 normal = AM_Utils.GetNormalFromTracer(res);

		return collided, normal, tracer;
	}

	override ETraceStatus TraceCallback()
	{
		int res = TRACE_Skip;

		switch (results.HitType)
		{
		case TRACE_HitActor:
			if (results.HitActor && results.HitActor.bSolid)
			{
				res = TRACE_Stop;
			}
			break;
		case TRACE_HitWall:
		case TRACE_HasHitSky:
		case TRACE_HitFloor:
		case TRACE_HitCeiling:
			res = TRACE_Stop;
			break;
		}

		return res;
	}
}