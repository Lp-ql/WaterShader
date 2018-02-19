using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Renderer))]
public class WaterMovement : MonoBehaviour
{
    [SerializeField]
    private float speed;

    private Material material;
    private Vector2 p1, p2, v1, v2;
    private float a1, a2;

    private const float pi = Mathf.PI;

    void Start()
    {
        material = GetComponent<Renderer>().material;
        a1 = Random.Range(-pi, pi);
        a2 = Random.Range(-pi, pi);
        v1 = new Vector2(Mathf.Cos(a1), Mathf.Sin(a1)) * speed;
        v2 = new Vector2(Mathf.Cos(a2), Mathf.Sin(a2)) * speed;
    }

    void Update()
    {
        p1 += v1 * Time.deltaTime;
        p2 += v2 * Time.deltaTime;
        a1 += Random.Range(-pi, pi) * 0.1f * Time.deltaTime;
        a1 += Random.Range(-pi, pi) * 0.1f * Time.deltaTime;
        v1 = new Vector2(Mathf.Cos(a1), Mathf.Sin(a1)) * speed;
        v2 = new Vector2(Mathf.Cos(a2), Mathf.Sin(a2)) * speed;

        material.SetVector("_Offset", new Vector4(p1.x, p1.y, p2.x, p2.y));
    }
}
