using static raylib_beef.Raylib;
using raylib_beef.Types;
using System;
using Boids.lib;
namespace Boids
{
	public class MainMenu
	{
		Button button = new Button(.(500, 360), .(200, 50), Color.RAYWHITE, "Start");
		Textfield title = new Textfield(.(450, 250), .(200, 50), Color.BLACK, "EcoBoid", 64);
		Textfield titleSub = new Textfield(.(380, 300), .(200, 50), Color.BLACK, "An ecosystem simulation using boids", 24);
		


		public this()
		{
			button.onClick.Add(new () =>
				{
					app.Init();
				}
			);
		}
		public void Draw()
		{
			title.Draw();
			titleSub.Draw();

			
			button.Draw();
		}
		public void Update()
		{
			button.Update();
		}
	}
}
