using raylib_beef.Types;
using System;
namespace Boids.lib
{
	public class VecExtensions
	{
		public static Vector2 limitVec(this ref Vector2 vec, float maxLength) 
		{

			let lengthSquared = vec.x * vec.x + vec.y * vec.y;

			if ((lengthSquared > maxLength * maxLength) && (lengthSquared > 0))
			{
				let ratio = maxLength / Math.Sqrt(lengthSquared);
				vec.x *= ratio;
				vec.y *= ratio;
			}

			return vec;
		}

	}
}
