using static raylib_beef.Raylib;
using raylib_beef.Types;
using static raylib_beef.Raymath;
using System;
namespace Boids.lib
{
	/*
	Title: Textfield
	Description:Simple class to display text for UI elements.
	*/
	class Textfield : UIElement
	{
		public String Text;
		float textWidth;
		public int32 fontSize;
		Color cTemp;
		public this(Vector2 pos, Vector2 size, Color c, String text, int32 fontsize=12) : base(pos, size, c)
		{
			Position=pos;
			Size=size;
			color=c;
			cTemp=color;//Store base color
			Text=text;
			fontSize=fontsize;
			textWidth=MeasureText(text,(fontsize));

			Bounds=.(Position.x,Position.y,textWidth,Size.y);
		}
		public this(Rectangle rect, Color c, String text, int32 fontsize=12) : base(rect,c)
		{
			Position=.(rect.x,rect.y);
			Size=.(rect.width,rect.height);
			Bounds=rect;
			Text=text;
			fontSize=fontsize;
			textWidth=MeasureText(text,(fontsize));
			color=c;
		}

		public override void Draw()
		{
			base.Draw();
			DrawText(Text,int32(Position.x),int32(Position.y),fontSize,color);
		}
		public override void Update()
		{
			base.Update();
		}
	}
}
