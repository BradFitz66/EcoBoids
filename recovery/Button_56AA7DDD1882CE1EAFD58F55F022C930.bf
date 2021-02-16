using static raylib_beef.Raylib;
using raylib_beef.Types;
using static raylib_beef.Raymath;
using System;
namespace Boids.lib
{
	class Button : Entity
	{
		public Color c;
		public String text="";
		public Vector2 ScreenRelativePosition;
		Font font=Font();

		public Event<delegate void()> clickEvt=default;

		public this(float x, float y, float width, float height, String Text="Start")
		{
			position = .(x, y);
			aabb = .(x, y, width, height);

			ScreenRelativePosition = .(baseScreenWidth - aabb.x, baseScreenHeight - aabb.y);
			ScreenRelativePosition = Vector2DivideV(ScreenRelativePosition, .(baseScreenWidth, baseScreenHeight));
			text=Text;
			c = Color.RAYWHITE;
		}

		public override void Draw()
		{
			base.Draw();

			DrawRectangleRec(.(position.x - aabb.width / 2, position.y - aabb.height / 2, aabb.width, aabb.height), c);
			DrawText(text, int32(position.x - aabb.width /4), int32(position.y - aabb.height / 2),48,Color.BLACK);
		}

		public bool isWithinaabb(float x, float y){
			return x >= position.x-aabb.width/2 && x < position.x + this.aabb.width/2 &&
				y >= position.y-aabb.height/2 && y < position.y + this.aabb.height/2;

		}
		public override void Update()
		{
			position.x = GetScreenWidth() * ScreenRelativePosition.x;
			position.y = GetScreenHeight() * ScreenRelativePosition.y;

			Vector2 worldMousePos = (GetMousePosition());
			float x = worldMousePos.x;
			float y = worldMousePos.y;

			float x2 = position.x;
			float y2 = position.y;

			isMouseOver = isWithinaabb(x,y);

			if (isMouseOver)
			{
				if(IsMouseButtonDown(raylib_beef.Enums.MouseButton.MOUSE_LEFT_BUTTON)){
					c = Color.GRAY;
					clickEvt.Invoke();
				}
				else
					c = .(uint8(Color.WHITE.r/1.25f),uint8(Color.WHITE.b/1.25f),uint8(Color.WHITE.g/1.25f),255);
			}
			else
			{
				c = Color.RAYWHITE;
			}
			base.Update();
		}
	}
}
