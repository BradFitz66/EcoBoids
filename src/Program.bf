using System;
using static raylib_beef.Raylib;
using static raylib_beef.rlgl;
using ImGui;
using raylib_beef.Enums;
namespace Boids
{
	static{
		public static bool useSpatialHash=false;
	}
	class Program
	{
		static GameApp gApp;
		static void Main(String[] args){

			SetConfigFlags(ConfigFlag.FLAG_WINDOW_RESIZABLE);
			InitWindow(1200, 720, "Boids");
			//SetTargetFPS(120);
			
			gApp=scope GameApp();
			while (!WindowShouldClose())
			{

				
				DrawFPS(GetScreenWidth()-90,GetScreenHeight()-50);
					gApp.Update();
				BeginDrawing();
					gApp.Draw();
				EndDrawing();

			}
			CloseWindow();
		}
	}
}
