using System;
using SDL2;
namespace Boids.Utils
{
	class Utils
	{
		public void DrawString(float x, float y, String str, SDL.Color color, SDL2.SDL.Renderer *mRenderer,Font font ,bool centerX=false)
		{
			var x;

			SDL.SetRenderDrawColor(mRenderer, 255, 255, 255, 255);
			let surface = SDLTTF.RenderUTF8_Blended(font.mFont, str, color);
			let texture = SDL.CreateTextureFromSurface(mRenderer, surface);
			SDL.Rect srcRect = .(0, 0, surface.w, surface.h);

			if (centerX)
				x -= surface.w / 2;

			SDL.Rect destRect = .((int32)x, (int32)y, surface.w, surface.h);
			SDL.RenderCopy(mRenderer, texture, &srcRect, &destRect);
			SDL.FreeSurface(surface);
			SDL.DestroyTexture(texture);
		}
	}
}
