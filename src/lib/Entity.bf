using raylib_beef.Types;
using static raylib_beef.Raylib;
using static raylib_beef.Raymath;
using static raylib_beef.Physac;

using System.Collections;
namespace Boids.lib
{
	/*
	Title: Entity
	Description: Base class for entities such as Boids
	*/
	class Entity
	{
		public Vector2 position;
		public float Scale;
		public float Rotation;
		public Rectangle aabb=.(0,0,0,0);
		
		public bool isMouseOver;

		public virtual void Update() {}
		public virtual void Draw() {}
	}
}
