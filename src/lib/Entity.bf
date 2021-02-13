using raylib_beef.Types;
using static raylib_beef.Raylib;
using static raylib_beef.Raymath;
using System.Collections;
namespace Boids.lib
{
	class Entity
	{
		public Vector2 position;
		public float Scale;
		public float Rotation;
		public virtual void Update() {}
		public virtual void Draw() {}
	}
}
