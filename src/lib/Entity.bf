using raylib_beef.Types;
using static raylib_beef.Raylib;
using static raylib_beef.Raymath;
using static raylib_beef.Physac;

using System;
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
		public Event<delegate void()> onClick;
		public bool IsMouseOver(){
			return CheckCollisionPointRec(GetScreenToWorld2D(GetMousePosition(),cam),aabb);
		}

		public ~this(){
			onClick.Dispose();
		}

		[Inline]
		public virtual void Update() {
			if(IsMouseOver() && IsMouseButtonPressed(.MOUSE_LEFT_BUTTON)){
				Console.Write("Clicked!");
				onClick.Invoke();
			}
		}
		public virtual void Draw() {}
	}
}
