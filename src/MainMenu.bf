using static raylib_beef.Raylib;
using System;
using Boids.lib;
namespace Boids
{
	public class MainMenu
	{
		Button b = new Button(600,360,200,50);
		public this(){
			b.clickEvt.Add(new ()=>{app.Init();});
		}
		public void Draw(){
			b.Draw();
		}
		public void Update(){
			b.Update();
		}

	}
}
