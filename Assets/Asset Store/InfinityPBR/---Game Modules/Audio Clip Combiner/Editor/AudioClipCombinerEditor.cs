using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using InfinityPBR.Modules;
using UnityEditor;
using UnityEngine;

namespace InfinityPBR
{
    [CustomEditor(typeof(AudioClipCombiner))]
    [CanEditMultipleObjects]
    [Serializable]
    public class AudioClipCombinerEditor : Editor
    {
        private AudioClipCombiner ThisObject;
        private int _updateData = -1;
        
        private void OnEnable() => ThisObject = (AudioClipCombiner) target;
        private void OnValidate() => ThisObject.Validations();

        public override void OnInspectorGUI()
        {
            UpdateData();
            ThisObject.Validations();
            ShowInstructions();
            
            Undo.RecordObject(ThisObject, "Undo Changes");
            ShowMainDetails();
            ShowAudioLayers();
            ShowFullInspector();
            
            EditorUtility.SetDirty(ThisObject);
        }

        private void UpdateData()
        {
            if (_updateData < 0) return;

            UpdateData(ThisObject.audioLayers[_updateData]);
            _updateData = -1;
        }

        private void ShowMainDetails()
        {
            EditorGUILayout.Space();
            ThisObject.outputName = EditorGUILayout.TextField("Output name", ThisObject.outputName);
            
            ExportButton();
            ExportData();
        }

        private void ExportButton()
        {
            GUI.backgroundColor = CanExport() ? Color.green : Color.black;
            GUI.contentColor = CanExport() ? Color.white : Color.grey;
            if(GUILayout.Button($"Export {ThisObject.TotalExports()} Clip Combinations") && CanExport()) ThisObject.SaveNow();
            GUI.backgroundColor = Color.white;
            GUI.contentColor = Color.white;
        }

        private void ExportData()
        {
            if (!CanExport()) return;
            
            EditorGUILayout.LabelField($"Exported Clips: {ThisObject.TotalExports()} files from {ThisObject.audioLayers.Count} Audio Layers");
            EditorGUILayout.LabelField($"Clip Durations: {ThisObject.shortestClipLength} to {ThisObject.longestClipLength} seconds");
        }

        public bool CanExport()
        {
            if (ThisObject.audioLayers.Count == 0) return false;
            if (!ThisObject.audioLayers.All(x => x.HasClips())) return false;
            if (ThisObject.audioLayers.Count < 2) return false;

            return true;
        }

        private void ShowInstructions()
        {
            EditorGUILayout.HelpBox($"At least two Audio Layers are required. All Audio Layers must have at least one Audio Clip.\n\n" +
                                    $"Audio Layers will be combined " +
                                    $"together and exported as stand-alone AudioClip (.wav) files. If you add multiple " +
                                    $"AudioClip files to an Audio Layer, every combination of potential clips will be " +
                                    $"exported.\n\nFiles will be exported to {ThisObject.PathOutput}", MessageType.Info);
            
            if (!File.Exists(ThisObject.PathExample)) return;
            
            EditorGUILayout.HelpBox($"Exports will overwrite existing files in {ThisObject.PathOutput} etc", MessageType.Warning);
        }

        private void ShowAudioLayers()
        {
            EditorGUILayout.Space();

            foreach (AudioClipCombiner.AudioLayer audioLayer in ThisObject.audioLayers)
                ShowAudioLayer(audioLayer);

            ShowAddNewAudioLayer();
        }

        private void ShowAudioLayer(AudioClipCombiner.AudioLayer audioLayer)
        {
            CheckName(audioLayer);
            if (audioLayer.expanded) EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            EditorGUILayout.BeginHorizontal();
            //audioLayer.expanded = EditorGUILayout.Foldout(audioLayer.expanded, audioLayer.name);
            if (GUILayout.Button(audioLayer.expanded ? "O" : "-", GUILayout.Width(25)))
                audioLayer.expanded = !audioLayer.expanded;
            
            audioLayer.name = EditorGUILayout.TextField(audioLayer.name, GUILayout.Width(150));
            
            EditorGUILayout.LabelField("", GUILayout.Width(20));
            EditorGUILayout.LabelField(new GUIContent("Volume", "Relative to the default volume of the clip"), GUILayout.Width(50));
            audioLayer.volume = EditorGUILayout.FloatField(audioLayer.volume, GUILayout.Width(30));
            
            EditorGUILayout.LabelField("", GUILayout.Width(20));
            EditorGUILayout.LabelField(new GUIContent("Delay", "Empty space before this clip comes in"),GUILayout.Width(50));
            var tempDelay = audioLayer.delay;
            audioLayer.delay = EditorGUILayout.FloatField(audioLayer.delay, GUILayout.Width(30));
            if (tempDelay != audioLayer.delay)
                UpdateData(audioLayer);

            EditorGUILayout.LabelField("", GUILayout.Width(20));
            GUI.contentColor = audioLayer.clips.Count == 0 ? Color.red : Color.grey;
            EditorGUILayout.LabelField($"Clips: {audioLayer.clips.Count}", GUILayout.Width(70));
            if (audioLayer.clips.Count > 0)
            {
                EditorGUILayout.LabelField($"Length: {audioLayer.shortestClipLength}{(audioLayer.clips.Count > 1 ? $" - {audioLayer.longestClipLength}" : "")}", GUILayout.Width(200));
            }
            GUI.contentColor = Color.white;
            
            EditorGUILayout.EndHorizontal();
            
            if (!audioLayer.expanded) return;

            for (int i = 0; i < audioLayer.clips.Count; i++)
                ShowClip(audioLayer, i);
            AddNewClip(audioLayer);
            

            GUI.color = Color.red;
            if (GUILayout.Button($"Remove {audioLayer.name}", GUILayout.Width(200)))
            {
                ThisObject.audioLayers.RemoveAll(x => x == audioLayer);
                GUIUtility.ExitGUI();
            }
            GUI.color = Color.white;
            EditorGUILayout.EndVertical();
            
            EditorGUILayout.Space();
        }

        private void ShowClip(AudioClipCombiner.AudioLayer audioLayer, int i)
        {
            EditorGUILayout.BeginHorizontal();
            ShowClipDelete(audioLayer, i);
            ShowClipObject(audioLayer, i);
            ShowClipData(audioLayer, i);
            EditorGUILayout.EndHorizontal();
        }

        private void ShowClipData(AudioClipCombiner.AudioLayer audioLayer, int i)
        {
            var clip = audioLayer.clips[i];
            GUI.color = clip.length == audioLayer.shortestClipLength || clip.length == audioLayer.longestClipLength ? Color.cyan : Color.grey;
            EditorGUILayout.LabelField($"Length: {clip.length}", GUILayout.Width(120));
            GUI.color = Color.grey;
            EditorGUILayout.LabelField($"Frequency: {clip.frequency}", GUILayout.Width(120));
            EditorGUILayout.LabelField($"Channels: {clip.channels}", GUILayout.Width(80));
            EditorGUILayout.LabelField($"Samples: {clip.samples}", GUILayout.Width(120));
            GUI.color = Color.white;
        }

        private void ShowClipObject(AudioClipCombiner.AudioLayer audioLayer, int i)
        {
            var tempClip = audioLayer.clips[i];
            audioLayer.clips[i] = EditorGUILayout.ObjectField(audioLayer.clips[i], typeof(AudioClip), GUILayout.Width(150)) as AudioClip;
            if (tempClip != audioLayer.clips[i])
                UpdateData(audioLayer);
        }

        private void UpdateData(AudioClipCombiner.AudioLayer audioLayer = null)
        {
            if (audioLayer != null)
            {
                audioLayer.UpdateLengths();
            }
            
            ThisObject.UpdateLengths();
        }

        private void ShowClipDelete(AudioClipCombiner.AudioLayer audioLayer, int i)
        {
            GUI.color = Color.red;
            if (GUILayout.Button("X", GUILayout.Width(20)))
            {
                audioLayer.clips.RemoveAt(i);
                _updateData = i;
                GUIUtility.ExitGUI();
            }
            GUI.color = Color.white;
        }

        private void AddNewClip(AudioClipCombiner.AudioLayer audioLayer)
        {
            GUI.color = Color.yellow;
            var newClip = EditorGUILayout.ObjectField("Add Clip", null, typeof(AudioClip)) as AudioClip;
            GUI.color = Color.white;

            if (newClip == null) return;
            audioLayer.AddClip(newClip);
            ThisObject.UpdateLengths();
        }

        private void CheckName(AudioClipCombiner.AudioLayer audioLayer)
        {
            if (string.IsNullOrWhiteSpace(audioLayer.name)) audioLayer.name = "Unnamed Audio Layer";
            audioLayer.name = audioLayer.name.Trim();
        }

        private void ShowAddNewAudioLayer()
        {
            GUI.color = Color.yellow;
            if (GUILayout.Button("Add new Audio Layer", GUILayout.Width(200)))
            {
                ThisObject.audioLayers.Add(new AudioClipCombiner.AudioLayer());
                var newObject = ThisObject.audioLayers.Last();
                newObject.volume = 1f;
                newObject.delay = 0f;
                newObject.name = "Unnamed Audio Layer";
                newObject.expanded = true;
                newObject.parent = ThisObject;
                GUIUtility.ExitGUI();
            }
            GUI.color = Color.white;
        }

        private void ShowFullInspector()
        {
            EditorGUILayout.Space();
            ThisObject.displayInspector =
                EditorGUILayout.ToggleLeft("Show full inspector", ThisObject.displayInspector);

            if (!ThisObject.displayInspector) return;
            
            DrawDefaultInspector();
        }
    }
}
