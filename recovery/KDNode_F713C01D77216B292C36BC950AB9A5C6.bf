using System;
using System.Collections;
using System.Text;

namespace KDTree
{
    /// <summary>
    /// A KD-Tree node which supports a generic number of dimensions.  All data items
    /// need the same number of dimensions.
    /// This node splits based on the largest range of any dimension.
    /// </summary>
    /// <typeparam name="T">The generic data type this structure contains.</typeparam>
    /// <remarks>This is based on this: https://bitbucket.org/rednaxela/knn-benchmark/src/tip/ags/utils/dataStructures/trees/thirdGenKD/ </remarks>
    public class KDNode<T>
    {
        #region  properties and constructor
        // All types
        /// <summary>
        /// The number of dimensions for this node.
        /// </summary>
        public  int iDimensions;

        /// <summary>
        /// The maximum capacity of this node.
        /// </summary>
        public  int iBucketCapacity;

        // Leaf only
        /// <summary>
        /// The array of locations.  [index][dimension]
        /// </summary>
        public  List<List<double>> tPoints ~ DeleteContainerAndItems!(_);

        /// <summary>
        /// The array of data values. [index]
        /// </summary>
        public  T[] tData ~ delete _;

        // Stem only
        /// <summary>
        /// The left and right children.
        /// </summary>
        public  KDNode<T> pLeft, pRight;
        /// <summary>
        /// The split dimension.
        /// </summary>
        public  int iSplitDimension;
        /// <summary>
        /// The split value (larger go into the right, smaller go into left)
        /// </summary>
        public  double fSplitValue;

        // Bounds
        /// <summary>
        /// The min and max bound for this node.  All dimensions.
        /// </summary>
		public  List<double> tMinBound ~ delete _;
        public  List<double> tMaxBound ~ delete _;

        /// <summary>
        /// Does this node represent only one point.
        /// </summary>
        public  bool bSinglePoint;

        /// <summary>
        /// public method which constructs a new KDNode.
        /// </summary>
        /// <param name="iDimensions">The number of dimensions for this node (all the same in the tree).</param>
        /// <param name="iBucketCapacity">The initial capacity of the bucket.</param>
        public this(int iDimensions, int iBucketCapacity)
        {
            // Variables.
            this.iDimensions = iDimensions;
            this.iBucketCapacity = iBucketCapacity;
            this.Size = 0;
            this.bSinglePoint = true;

            // Setup leaf elements.
            this.tPoints = new List<List<double>>(iBucketCapacity+1);
            this.tData = new T[iBucketCapacity+1];
        }
        #endregion

        #region External Operations
        /// <summary>
        /// The number of items in this leaf node and all children.
        /// </summary>
        public int Size { get; private set; }

        /// <summary>
        /// Is this KDNode a leaf or not?
        /// </summary>
        public bool IsLeaf { get { return tPoints != null; } }

        /// <summary>
        /// Insert a new point into this leaf node.
        /// </summary>
        /// <param name="tPoint">The position which represents the data.</param>
        /// <param name="kValue">The value of the data.</param>
        public void AddPoint(List<double> tPoint, T kValue)
        {
            // Find the correct leaf node.
            KDNode<T> pCursor = this;
            while (!pCursor.IsLeaf)
            {
                // Extend the size of the leaf.
                pCursor.ExtendBounds(tPoint);
                pCursor.Size++;

                // If it is larger select the right, or lower,  select the left.
                if (tPoint[pCursor.iSplitDimension] > (double)pCursor.fSplitValue)
                {
                    pCursor = pCursor.pRight;
                }
                else
                {
                    pCursor = pCursor.pLeft;
                }
            }

            // Insert it into the leaf.
            pCursor.AddLeafPoint(tPoint, kValue);
        }
        #endregion

        #region  Operations
        /// <summary>
        /// Insert the point into the leaf.
        /// </summary>
        /// <param name="tPoint">The point to insert the data at.</param>
        /// <param name="kValue">The value at the point.</param>
        private void AddLeafPoint(List<double> tPoint, T kValue)
        {
            // Add the data point to this node.
            tPoints[Size] = tPoint;
            tData[Size] = kValue;
            ExtendBounds(tPoint);
            Size++;

            // Split if the node is getting too large in terms of data.
            if (Size == tPoints.Count - 1)
            {
                // If the node is getting too physically large.
                if (CalculateSplit())
                {
                    // If the node successfully had it's split value calculated, split node.
                    SplitLeafNode();
                }
                else
                {
                    // If the node could not be split, enlarge node data capacity.
                    IncreaseLeafCapacity();
                }
            }
        }

        /// <summary>
        /// If the point lies outside the boundaries, return false else true.
        /// </summary>
        /// <param name="tPoint">The point.</param>
        /// <returns>True if the point is inside the boundaries, false outside.</returns>
        private bool CheckBounds(double[] tPoint)
        {
            for (int i = 0; i < iDimensions; ++i)
            {
                if (tPoint[i] > tMaxBound[i]) return false;
                if (tPoint[i] < tMinBound[i]) return false;
            }
            return true;
        }

        /// <summary>
        /// Extend this node to contain a new point.
        /// </summary>
        /// <param name="tPoint">The point to contain.</param>
        private void ExtendBounds(List<double> tPoint)
        {
            // If we don't have bounds, create them using the new point then bail.
            if (tMinBound == null) 
            {
                tMinBound = new List<double>(iDimensions);
                tMaxBound = new List<double>(iDimensions);

				for(int i=0; i<tPoints.Count; i++){
					tMinBound[i]=(double)tPoints[i][i];
					tMaxBound[i]=(double)tPoints[i][i];
				}
                return;
            }

            // For each dimension.
            for (int i = 0; i < iDimensions; ++i)
            {
                if ((double)tPoint[i] == (double)double.NaN)
                {
                    if ((tMinBound[i])==double.NaN || double.NaN==(tMaxBound[i]))
                        bSinglePoint = false;
                    
                    tMinBound[i] = double.NaN;
                    tMaxBound[i] = double.NaN;
                }
                else if ((double)tMinBound[i] > tPoint[i])
                {
                    tMinBound[i] = (double)tPoint[i];
                    bSinglePoint = false;
                }
                else if ((double)tMaxBound[i] < tPoint[i])
                {
                    tMaxBound[i] = (double)tPoint[i];
                    bSinglePoint = false;
                }
            }
        }


	

        /// <summary>
        /// double the capacity of this leaf.
        /// </summary>
        private void IncreaseLeafCapacity()
        {
        }

        /// <summary>
        /// Work out if this leaf node should split.  If it should, a new split value and dimension is calculated
        /// based on the dimension with the largest range.
        /// </summary>
        /// <returns>True if the node split, false if not.</returns>
        private bool CalculateSplit()
        {
            // Don't split if we are just one point.
            if (bSinglePoint)
                return false;

            // Find the dimension with the largest range.  This will be our split dimension.
            double fWidth = 0;
            for (int i = 0; i < iDimensions; i++)
            {
                double fDelta = (tMaxBound[i] - tMinBound[i]);
                if (double.NaN==(fDelta))
                    fDelta = 0;

                if (fDelta > fWidth)
                {
                    iSplitDimension = i;
                    fWidth = fDelta;
                }
            }

            // If we are not wide (i.e. all the points are in one place), don't split.
            if (fWidth == 0)
                return false;

            // Split in the middle of the node along the widest dimension.
            fSplitValue = (tMinBound[iSplitDimension] + tMaxBound[iSplitDimension]) * 0.5;

            // Never split on infinity or NaN.
            if (fSplitValue == double.PositiveInfinity)
                fSplitValue = double.MaxValue;
            else if (fSplitValue == double.NegativeInfinity)
                fSplitValue = double.MinValue;
            
            // Don't let the split value be the same as the upper value as
            // can happen due to rounding errors!
            if (fSplitValue == tMaxBound[iSplitDimension])
                fSplitValue = tMinBound[iSplitDimension];

            // Success
            return true;
        }

        /// <summary>
        /// Split this leaf node by creating left and right children, then moving all the children of
        /// this node into the respective buckets.
        /// </summary>
        private void SplitLeafNode()
        {
            // Create the new children.
            pRight = new KDNode<T>(iDimensions, iBucketCapacity);
            pLeft  = new KDNode<T>(iDimensions, iBucketCapacity);

            // Move each item in this leaf into the children.
            for (int i = 0; i < Size; ++i)
            {
                // Store.
                List<double> tOldPoint = tPoints[i];
                T kOldData = tData[i];

                // If larger, put it in the right.
                if (tOldPoint[iSplitDimension] > (double)fSplitValue)
                    pRight.AddLeafPoint(tOldPoint, kOldData);

                // If smaller, put it in the left.
                else
                    pLeft.AddLeafPoint(tOldPoint, kOldData);
            }

            // Wipe the data from this KDNode.
            tPoints = null;
            tData = null;
        }
        #endregion
    }
}
