using static raylib_beef.Raylib;
using raylib_beef.Types;
using static raylib_beef.Raymath;
using System;
namespace Boids.lib
{
	public enum Pivot{
		CORNER,
		CENTER
	}
	/*
		Title: UIElement
		Description: Base class for UI elements such as buttons, textfields, etc.
	*/
	class UIElement
	{
		public Vector2 Position;
		public Vector2 RelativePosition{get; private set;};
		public Vector2 Size;
		public Pivot pivot = Pivot.CENTER;
		public Rectangle Bounds;
		public bool isMouseOver => IsMouseOver();
		public Color color;

		public this(Vector2 pos, Vector2 size, Color c){
		}

		public this(Rectangle rect, Color c){
			
		}
		private bool IsMouseOver(){

			return CheckCollisionPointRec(GetMousePosition(),.(Position.x,Position.y,Bounds.width,Bounds.height));
		}
		private void UpdateRelativePosition(){
			RelativePosition=Vector2DivideV(.(baseScreenWidth - (pivot==Pivot.CORNER? Bounds.x : Bounds.x + (Bounds.width/2)), baseScreenHeight - (pivot==Pivot.CORNER? Bounds.y : Bounds.y + (Bounds.height/2))),.(baseScreenWidth,baseScreenHeight));
		}

		public virtual void Draw(){
			UpdateRelativePosition();
			Position.x=GetScreenWidth()*RelativePosition.x;
			Position.y=GetScreenHeight()*RelativePosition.y;

		}
		public virtual void Update(){
		}
	}
}
