using static raylib_beef.Raylib;
using raylib_beef.Types;
using System;
using Boids.lib;
namespace Boids
{
	public class MainMenu
	{
		Button b = new Button(.(600,360),.(200,50),Color.RAYWHITE,"Test");
		Textfield t = new Textfield(.(600,460),.(200,50),Color.BLACK,"EcoBoid",64);
		public this(){
			//b.clickEvt.Add(new ()=>{app.Init();});
		}
		public void Draw(){
			t.Draw();
			b.Draw();
		}
		public void Update(){
			b.Update();
		}

	}
}
