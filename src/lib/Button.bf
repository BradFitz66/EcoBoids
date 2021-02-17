using static raylib_beef.Raylib;
using raylib_beef.Types;
using static raylib_beef.Raymath;
using System;
namespace Boids.lib
{
	/*
	Title: Button
	Description:Simple class to display a button with text for UI elements.
	I should probably make a separate class called UIElement instead of using Entity and handle all position calculations inside there instead of in here.
	*/
	class Button : UIElement
	{
		public Event<delegate void()> onClick=default;
		public Textfield Text;
		Color cTemp;
		public this(Vector2 pos, Vector2 size, Color c, String text) : base(pos, size, c)
		{
			Position=pos;
			Size=size;
			color=c;
			cTemp=color;//Store base color
			Bounds=.(Position.x,Position.y,Size.x,Size.y);
			Text=new Textfield(pos,size,Color.BLACK,text,48);
		}
		public this(Rectangle rect, Color c, String text) : base(rect,c)
		{
			Position=.(rect.x,rect.y);
			Size=.(rect.width,rect.height);
			Bounds=rect;
			Text=new Textfield(.(rect.x,rect.y),.(rect.width,rect.height),Color.BLACK,text,48);
			color=c;
		}

		public override void Draw()
		{
			base.Draw();
			
			DrawRectangleV(Position,Size,color);
			if(Text.Text!=""){
				Text.Draw();
			}
		}
		public override void Update()
		{
			base.Update();
			if(isMouseOver){
				color=.(uint8(float(cTemp.r/1.1f)),uint8(float(cTemp.g/1.1f)),uint8(float(cTemp.b/1.1f)),255);
				if(IsMouseButtonDown(raylib_beef.Enums.MouseButton.MOUSE_LEFT_BUTTON)){
					color=.(uint8(float(cTemp.r/1.25f)),uint8(float(cTemp.g/1.25f)),uint8(float(cTemp.b/1.25f)),255);
					onClick.Invoke();
				}
			}
			else{
				color=cTemp;
			}
		}
	}
}
