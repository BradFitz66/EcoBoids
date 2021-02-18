using static raylib_beef.Raylib;
using raylib_beef.Types;
using System;
using Boids.lib;
namespace Boids
{
	public class MainMenu
	{
		Button b = new Button(.(600, 360), .(200, 50), Color.RAYWHITE, "Start");
		Textfield t = new Textfield(.(600, 500), .(200, 50), Color.BLACK, "EcoBoid", 64);
		Textfield t2 = new Textfield(.(600, 425), .(200, 50), Color.BLACK, "An ecosystem simulation using boids", 24);
		InputField i = new InputField(.(600, 460), .(300, 50), Color.RAYWHITE, "Boid amount");

		bool _isEnteringStuff = false;

		bool isEnteringStuff
		{
			get { return _isEnteringStuff; }
			set
			{
				b.Text.Text = value ? "Begin" : "Start";^
				_isEnteringStuff = value;
			}
		};

		public this()
		{
			b.onClick.Add(new () =>
				{
					if (!isEnteringStuff)
						{ isEnteringStuff = true; }
					else
						{ app.Init(); }
				}
			);
		}
		public void Draw()
		{
			if (!isEnteringStuff)
			{
				t.Draw();
				t2.Draw();
			}
			else
				i.Draw();

			b.Draw();
		}
		public void Update()
		{
			b.Update();
			if (isEnteringStuff)
			{
				i.Update();
			}
		}
	}
}
