using System;
using System.Collections;
namespace Boids.lib
{
	//A fixed size list for containing other boids.
	public class OtherBoids : List<Entity>
	{
		public int mSize{get;private set;};
		public bool atMaxCapacity{get{
			return Count==mSize;
		}}
		public this(int maxSize=10000) : base(){
			mSize=maxSize;
		}

		public void Insert(Entity b){
			if(Count==mSize){
				return;
			}
			Add(b);
		}
		public void InsertRange(Span<Entity> range){
			Span<Entity> r = range;
			if(r.Length>mSize)
				r.RemoveFromEnd(r.Length - (OmSize);
			for (var val in ref r){
				Insert(val);
			}
		}
	}
}
