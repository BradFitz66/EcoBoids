using static raylib_beef.Raylib;
using raylib_beef.Types;
using static raylib_beef.Raymath;
using raylib_beef.Enums;
using System;

namespace Boids.lib
{
	/*
	Title: InputField
	Description: A field with text that can be modified by a user.
	*/
	class InputField : UIElement
	{
		Textfield Text;

		bool isFocused;

		Color cTemp;

		char8[4] input = "";

		int curInputAmount = 0;

		float inputDelay=0.1f;
		float inputDelayCounter=0.1f;

		String buffer = new String();
		public this(Vector2 pos, Vector2 size, Color c, String text) : base(pos, size, c)
		{
			Size = size;
			Position = pos;


			color = c;
			cTemp = color;
			Bounds = .(Position.x, Position.y, Size.x, Size.y);
			Text = new Textfield(Bounds, Color.BLACK, text, 48);
		}
		public ~this()
		{
			delete(buffer);
		}
		public override void Draw()
		{
			base.Draw();
			DrawRectangleV(Position, Size, color);
			Text.Draw();
		}
		public override void Update()
		{
			base.Update();
			if(inputDelayCounter<inputDelay)
				inputDelayCounter-=1*GetFrameTime();

			if(inputDelayCounter<=0)
				inputDelayCounter=inputDelay;
			if (IsMouseButtonDown(MouseButton.MOUSE_LEFT_BUTTON))
			{
				if (isMouseOver)
				{
					buffer.Clear();
					curInputAmount=0;
					input=.();
					isFocused = true;
					color=.(uint8(float(cTemp.r/1.1f)),uint8(float(cTemp.g/1.1f)),uint8(float(cTemp.b/1.1f)),255);
				}
				else
				{
					color=cTemp;
					isFocused = false;
				}
			}
			if (isFocused)
			{

				int32 key = GetKeyPressed();
				
				if ((key == 0 || curInputAmount >= 4) && !IsKeyDown(KeyboardKey.KEY_BACKSPACE))
					return;


				if (((char8)key).IsNumber || IsKeyDown(KeyboardKey.KEY_BACKSPACE)&&inputDelayCounter==inputDelay)
				{
					inputDelayCounter-=1*GetFrameTime();
					String b = scope String();
					if(IsKeyDown(KeyboardKey.KEY_BACKSPACE) && curInputAmount>0){
						input[curInputAmount] = '\0';
						input[curInputAmount].ToString(b);
						curInputAmount--;
						buffer.RemoveFromEnd(1);
					}
					else{
						input[curInputAmount] = (char8)key;
						input[curInputAmount].ToString(b);
						buffer.AppendF(b);
						curInputAmount++;
					}

					Text.Text = buffer;
				}
			}
		}
	}
}
