using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static MathHelper.XMathFunc;

namespace MathHelper
{
    public static class Vec
    {

        public static Vector3 Divide(in Vector3 v1, in Vector3 v2)
        {
            if (NearZero(v2.x) ||
                NearZero(v2.y) ||
                NearZero(v2.z))
            {
                Debug.LogError("Divide 0 vector3!");
            }
            return new Vector3(v1.x / v2.x, v1.y / v2.y, v1.z / v2.z);
        }

        public static Vector3 Mul(in Vector3 v1, in Vector3 v2)
        {
            return new Vector3(v1.x * v2.x, v1.y * v2.y, v1.z * v2.z);
        }

        public static Vector3Int MulToInt3(in Vector3 v1, in Vector3 v2)
        {
            return new Vector3Int((int)(v1.x * v2.x), (int)(v1.y * v2.y), (int)(v1.z * v2.z));
        }

        public static Vector3Int ToInt(in Vector3 v)
        {
            return new Vector3Int((int)v.x, (int)v.y, (int)v.z);
        }
    }
}