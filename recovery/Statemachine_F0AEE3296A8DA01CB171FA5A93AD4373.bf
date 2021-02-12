using System;
using System.Collections;
namespace Boids.lib
{

	struct State{
	}

	public class Statemachine<T> : ICollection<T> where T:State
	{


		public this(){
			List=new List<T>();
		}

		protected IList List {get;}

		public T this[int index] => (T)List[index];

		public void Add(T item)
		{
			
		}

		public void Clear()
		{

		}

		public bool Contains(T item)
		{
			return default;
		}

		public void CopyTo(Span<T> span)
		{

		}

		public bool Remove(T item)
		{
			return default;
		}
	}
}
