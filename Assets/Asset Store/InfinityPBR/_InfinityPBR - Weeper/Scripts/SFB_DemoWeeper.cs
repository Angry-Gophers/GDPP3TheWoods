using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SFB_DemoWeeper : MonoBehaviour {

	public Animator animator;
	public GameObject spell1;
	public GameObject[] spell2;
	public GameObject spell3;
	public GameObject[] spell4;
	public float cast1SpawnSpeed = 0.33f;
	public GameObject weeperExplosion;
	public Transform spell1Pos;
	public Transform spell3Pos;
	private GameObject latestSpell1;

	// Use this for initialization
	void Start () {
		animator = GetComponent<Animator> ();
	}
	
	public void Locomotion(float newValue){
		animator.SetFloat("locomotion", newValue);			// Update Variable in Animator
	}

	public void CastSpell1(){
		Quaternion newRotation = Quaternion.Euler(Random.Range(0,360), Random.Range(0,360), Random.Range(0,360));
		GameObject newSpell1 = Instantiate(spell1, spell1Pos.position, newRotation);
		//latestSpell1 = newSpell1;
		//Invoke("Explode", Random.Range(3.6f,3.9f));
		StartCoroutine(Explode(newSpell1, Random.Range(3.6f,3.9f)));
		//Destroy (newSpell1, 4.0f);
	}

	public void CastSpell3(){
		GameObject newSpell3 = Instantiate(spell3, spell3Pos.position, Quaternion.identity);
		Destroy(newSpell3, 10.0f);
	}

	public void StartCast1(){
		InvokeRepeating("CastSpell1", 0, cast1SpawnSpeed);
	}

	public void EndCast1(){
		CancelInvoke("CastSpell1");
	}

	/*public void Explode(){
		GameObject explosion = Instantiate(weeperExplosion, latestSpell1.transform.position, Quaternion.identity);
		Destroy(explosion, 3.0f);
	}*/

	IEnumerator Explode(GameObject obj, float delay)
	{
		yield return new WaitForSeconds(delay);
		GameObject explosion = Instantiate(weeperExplosion, obj.transform.position, Quaternion.identity);
		Destroy (obj);
		Destroy(explosion, 3.0f);
	}

	public void StartCast4(){
		for (int i = 0; i < spell4.Length; i++){
			if (spell4[i].GetComponent<ParticleSystem>())
				spell4[i].GetComponent<ParticleSystem>().Play();
			else
				spell4[i].SetActive(true);
		}
	}

	public void StopCast4(){
		for (int i = 0; i < spell4.Length; i++){
			if (spell4[i].GetComponent<ParticleSystem>())
				spell4[i].GetComponent<ParticleSystem>().Stop();
			else
				spell4[i].SetActive(false);
		}
	}

	public void StartCast2(){
		for (int i = 0; i < spell2.Length; i++){
			if (spell2[i].GetComponent<ParticleSystem>())
				spell2[i].GetComponent<ParticleSystem>().Play();
			else
				spell2[i].SetActive(true);
		}
	}

	public void StopCast2(){
		for (int i = 0; i < spell2.Length; i++){
			if (spell2[i].GetComponent<ParticleSystem>())
				spell2[i].GetComponent<ParticleSystem>().Stop();
			else
				spell2[i].SetActive(false);
		}
	}
}
