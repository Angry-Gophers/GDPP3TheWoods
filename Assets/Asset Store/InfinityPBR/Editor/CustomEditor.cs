using System;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;
using Object = UnityEngine.Object;

namespace InfinityPBR
{
    public abstract class CustomEditor<T> : Editor where T : Object
    {
        public static string symbolInfo = "ⓘ";
        public static string symbolX = "✘";
        public static string symbolCheck = "✔";
        public static string symbolCheckSquare = "☑";
        public static string symbolDollar = "$";
        public static string symbolCent = "¢";
        public static string symbolCarrotRight = "‣";
        public static string symbolCarrotLeft = "◄";
        public static string symbolCarrotUp = "▲";
        public static string symbolCarrotDown = "▼";
        public static string symbolDash = "⁃";
        public static string symbolBulletClosed = "⦿";
        public static string symbolBulletOpen = "⦾";
        public static string symbolHeartClosed = "♥";
        public static string symbolHeartOpen = "♡";
        public static string symbolStarClosed = "★";
        public static string symbolStarOpen = "☆";
        public static string symbolArrowUp = "↑";
        public static string symbolArrowDown = "↓";
        public static string symbolRandom = "↬";
        public static string symbolMusic = "♫";
        public static string symbolImportant = "‼";
        
        /*
        * ----------------------------------------------------------------------------------------------
        * BUTTONS, LABELS, ETC
        * ----------------------------------------------------------------------------------------------
        */
        
        // Horizontal Gap
        public static void Gap(int width = 20)
        {
            Label("", width);
        }

        // Buttons
        public static bool Button(string label, string tooltip, int width, int height)
        {
            if (GUILayout.Button(new GUIContent(label, tooltip), GUILayout.Width(width), GUILayout.Height(height)))
                return true;
            return false;
        }
        
        public static bool Button(string label, string tooltip, int width)
        {
            
            if (GUILayout.Button(new GUIContent(label, tooltip), GUILayout.Width(width)))
                return true;
            return false;
        }
        
        public static bool Button(string label, string tooltip)
        {
            if (GUILayout.Button(new GUIContent(label, tooltip)))
                return true;
            return false;
        }
        
        public static bool Button(string label, int width, int height)
        {
            if (GUILayout.Button(label, GUILayout.Width(width), GUILayout.Height(height)))
                return true;
            return false;
        }

        public static bool Button(string label, int width)
        {
            if (GUILayout.Button(label, GUILayout.Width(width)))
                return true;
            return false;
        }
        
        public static bool ButtonBig(string label, int width, int height = 24, int fontSize = 18, bool bold = false)
        {
            GUIStyle style = new GUIStyle(EditorStyles.miniButton)
            {
                fontSize = fontSize, 
                fixedHeight = height, 
                fixedWidth = width,
                fontStyle = bold ? FontStyle.Bold : FontStyle.Normal
            };
            if (GUILayout.Button(label, style))
                return true;
            return false;
        }

        public static bool Button(string label)
        {
            //Debug.Log("Button Name: " + label);
            if (GUILayout.Button(label))
                return true;
            return false;
        }

        // Label Fields
        public static void LabelBig(string label, int fontSize = 18, bool bold = false)
        {
            GUIStyle style = new GUIStyle(bold ? EditorStyles.boldLabel : EditorStyles.label);
            style.fontSize = fontSize;
            EditorGUILayout.LabelField(label, style, GUILayout.Height(fontSize));
        }

        public static void LabelBig(string label, int width, int fontSize = 18, bool bold = false)
        {
            GUIStyle style = new GUIStyle(bold ? EditorStyles.boldLabel : EditorStyles.label);
            style.fontSize = fontSize;
            EditorGUILayout.LabelField(label, style, GUILayout.Width(width), GUILayout.Height(fontSize));
        }
        
        public static void LabelBig(string label, string tooltip, int width, int fontSize = 18, bool bold = false)
        {
            GUIStyle style = new GUIStyle(bold ? EditorStyles.boldLabel : EditorStyles.label);
            style.fontSize = fontSize;
            EditorGUILayout.LabelField(new GUIContent(label, tooltip), style, GUILayout.Width(width), GUILayout.Height(fontSize));
        }
        
        public static void Label(string label, bool bold = false, bool wordwrap = false)
        {
            GUIStyle style = new GUIStyle(bold ? EditorStyles.boldLabel : EditorStyles.label);
            if (wordwrap) style.wordWrap = true;
            EditorGUILayout.LabelField(label, style);
        }
        
        public static void LabelGrey(string label, bool bold = false, bool wordwrap = false)
        {
            ContentColor(Color.grey);
            GUIStyle style = new GUIStyle(bold ? EditorStyles.boldLabel : EditorStyles.label);
            if (wordwrap) style.wordWrap = true;
            EditorGUILayout.LabelField(label, style);
            ContentColor(Color.white);
        }
        
        public static void LabelGrey(string label, int width, bool bold = false, bool wordwrap = false)
        {
            ContentColor(Color.grey);
            GUIStyle style = new GUIStyle(bold ? EditorStyles.boldLabel : EditorStyles.label);
            if (wordwrap) style.wordWrap = true;
            EditorGUILayout.LabelField(label, style, GUILayout.Width(width));
            ContentColor(Color.white);
        }
        
        public static void Label(string label, int width, bool bold = false, bool wordwrap = false)
        {
            GUIStyle style = new GUIStyle(bold ? EditorStyles.boldLabel : EditorStyles.label);
            if (wordwrap) style.wordWrap = true;
            EditorGUILayout.LabelField(label, style, GUILayout.Width(width));
        }
        
        public static void Label(string label, string tooltip, bool bold = false, bool wordwrap = false)
        {
            GUIStyle style = new GUIStyle(bold ? EditorStyles.boldLabel : EditorStyles.label);
            if (wordwrap) style.wordWrap = true;
            EditorGUILayout.LabelField(new GUIContent(label, tooltip), style);
        }
        
        public static void Label(string label, string tooltip, int width, bool bold = false, bool wordwrap = false)
        {
            GUIStyle style = new GUIStyle(bold ? EditorStyles.boldLabel : EditorStyles.label);
            if (wordwrap) style.wordWrap = true;
            EditorGUILayout.LabelField(new GUIContent(label, tooltip), style, GUILayout.Width(width));
        }
        
        // Sliders

        public static int SliderInt(int value, int min, int max) => Mathf.RoundToInt(EditorGUILayout.Slider((float) value, (float) min, (float) max));
        public static int SliderInt(string label, int value, int min, int max) => Mathf.RoundToInt(EditorGUILayout.Slider(label, (float) value, (float) min, (float) max));
        public static int SliderInt(int value, int min, int max, int width) => Mathf.RoundToInt(EditorGUILayout.Slider((float) value, (float) min, (float) max, GUILayout.Width(width)));
        public static int SliderInt(string label, int value, int min, int max, int width) => Mathf.RoundToInt(EditorGUILayout.Slider(label, (float) value, (float) min, (float) max, GUILayout.Width(width)));
        
        public static float SliderFloat(float value, float min, float max) => EditorGUILayout.Slider(value, min, max);
        public static float SliderFloat(string label, float value, float min, float max) => EditorGUILayout.Slider(label, value, min, max);
        public static float SliderFloat(float value, float min, float max, int width) => EditorGUILayout.Slider(value, min, max, GUILayout.Width(width));
        public static float SliderFloat(string label, float value, float min, float max, int width) => EditorGUILayout.Slider(label, value, min, max, GUILayout.Width(width));

        // Text Areas
        public static string TextArea(string text, int width, int height = 50)
        {
            GUIStyle style = new GUIStyle(EditorStyles.textArea);
            style.wordWrap = true;
            return EditorGUILayout.TextArea(text, style, GUILayout.Width(width), GUILayout.Height(height));
        }
        
        public static string TextArea(string text, int height = 50)
        {
            GUIStyle style = new GUIStyle(EditorStyles.textArea);
            style.wordWrap = true;
            return EditorGUILayout.TextArea(text, style, GUILayout.Height(height));
        }
        
        // Text Fields
        public static string TextField(string text, bool bold = false)
        {
            if (bold)
                return EditorGUILayout.TextField(text, EditorStyles.boldLabel);
            else
                return EditorGUILayout.TextField(text);
        }
        
        public static string TextField(string label, string text, bool bold = false)
        {
            if (bold)
                return EditorGUILayout.TextField(label, text, EditorStyles.boldLabel);
            else
                return EditorGUILayout.TextField(label, text);
        }
        
        public static string TextField(string label, string text, int width, bool bold = false)
        {
            if (bold)
                return EditorGUILayout.TextField(label, text, EditorStyles.boldLabel, GUILayout.Width(width));
            else
                return EditorGUILayout.TextField(label, text, GUILayout.Width(width));
        }
        
        public static string TextField(string label, string tooltip, string text, bool bold = false)
        {
            if (bold)
                return EditorGUILayout.TextField(new GUIContent(label, tooltip), text, EditorStyles.boldLabel);
            else
                return EditorGUILayout.TextField(new GUIContent(label, tooltip), text);
        }
        
        public static string TextField(string label, string tooltip, string text, int width, bool bold = false)
        {
            if (bold)
                return EditorGUILayout.TextField(new GUIContent(label, tooltip), text, EditorStyles.boldLabel, GUILayout.Width(width));
            else
                return EditorGUILayout.TextField(new GUIContent(label, tooltip), text, GUILayout.Width(width));
        }
        
        public static string TextField(string text, int width, bool bold = false)
        {
            if (bold)
                return EditorGUILayout.TextField(text, EditorStyles.boldLabel, GUILayout.Width(width));
            else
                return EditorGUILayout.TextField(text, GUILayout.Width(width));
        }
        
        public static string TextField(string text, int width, int height, bool bold = false)
        {
            if (bold)
                return EditorGUILayout.TextField(text, EditorStyles.boldLabel, GUILayout.Width(width), GUILayout.Height(height));
            else
                return EditorGUILayout.TextField(text, GUILayout.Width(width), GUILayout.Height(height));
        }

        // Delayed Text Fields
        public static string DelayedText(string text, bool bold = false)
        {
            if (bold)
                return EditorGUILayout.DelayedTextField(text, EditorStyles.boldLabel);
            else
                return EditorGUILayout.DelayedTextField(text);
        }
        
        public static string DelayedText(string label, string text, bool bold = false)
        {
            if (bold)
                return EditorGUILayout.DelayedTextField(label, text, EditorStyles.boldLabel);
            else
                return EditorGUILayout.DelayedTextField(label, text);
        }
        
        public static string DelayedText(string label, string text, int width, bool bold = false)
        {
            if (bold)
                return EditorGUILayout.DelayedTextField(label, text, EditorStyles.boldLabel, GUILayout.Width(width));
            else
                return EditorGUILayout.DelayedTextField(label, text, GUILayout.Width(width));
        }
        
        public static string DelayedText(string label, string tooltip, string text, bool bold = false)
        {
            if (bold)
                return EditorGUILayout.DelayedTextField(new GUIContent(label, tooltip), text, EditorStyles.boldLabel);
            else
                return EditorGUILayout.DelayedTextField(new GUIContent(label, tooltip), text);
        }
        
        public static string DelayedText(string label, string tooltip, string text, int width, bool bold = false)
        {
            if (bold)
                return EditorGUILayout.DelayedTextField(new GUIContent(label, tooltip), text, EditorStyles.boldLabel, GUILayout.Width(width));
            else
                return EditorGUILayout.DelayedTextField(new GUIContent(label, tooltip), text, GUILayout.Width(width));
        }
        
        public static string DelayedText(string text, int width, bool bold = false)
        {
            if (bold)
                return EditorGUILayout.DelayedTextField(text, EditorStyles.boldLabel, GUILayout.Width(width));
            else
                return EditorGUILayout.DelayedTextField(text, GUILayout.Width(width));
        }

        // Bool Checkboxes
        public static bool LeftCheck(string label, bool value) => EditorGUILayout.ToggleLeft(label, value);
        public static bool LeftCheck(string label, bool value, int width) => EditorGUILayout.ToggleLeft(label, value, GUILayout.Width(width));
        public static bool LeftCheck(string label, string tooltip, bool value) => EditorGUILayout.ToggleLeft(new GUIContent(label, tooltip), value);
        public static bool LeftCheck(string label, string tooltip, bool value, int width) => EditorGUILayout.ToggleLeft(new GUIContent(label, tooltip), value, GUILayout.Width(width));
        
        public static bool Check(string label, string tooltip, bool value) => EditorGUILayout.Toggle(new GUIContent(label, tooltip), value);
        public static bool Check(string label, string tooltip, bool value, int width) => EditorGUILayout.Toggle(new GUIContent(label, tooltip), value, GUILayout.Width(width));
        public static bool Check(string label, bool value) => EditorGUILayout.Toggle(label, value);
        public static bool Check(string label, bool value, int width) => EditorGUILayout.Toggle(label, value, GUILayout.Width(width));
        public static bool Check(bool value) => EditorGUILayout.Toggle(value);

        // Bool checkboxes that set prefs
        public static void LeftCheckSetBool(string boolName, string label) => SetBool(boolName, LeftCheck(label, GetBool(boolName)));

        public static bool Check(bool value, int width) => EditorGUILayout.Toggle(value, GUILayout.Width(width));

        // Float field
        public static float Float(string label, float value) => EditorGUILayout.FloatField(label, value);
        public static float Float(string label, float value, int width) => EditorGUILayout.FloatField(label, value, GUILayout.Width(width));
        public static float Float(float value) => EditorGUILayout.FloatField(value);
        public static float Float(float value, int width) => EditorGUILayout.FloatField(value, GUILayout.Width(width));
        
        public static float Float(string label, string tooltip, float value) => EditorGUILayout.FloatField(new GUIContent(label, tooltip), value);
        public static float Float(string label, string tooltip, float value, int width) => EditorGUILayout.FloatField(new GUIContent(label, tooltip), value, GUILayout.Width(width));

        // Int Field
        public static int Int(string label, int value) => EditorGUILayout.IntField(label, value);
        public static int Int(string label, int value, int width) => EditorGUILayout.IntField(label, value, GUILayout.Width(width));
        public static int Int(int value) => EditorGUILayout.IntField(value);
        public static int Int(int value, int width) => EditorGUILayout.IntField(value, GUILayout.Width(width));

        // Object Field
        public static Object Object(Object obj, Type objType, bool allowSceneObjects = false) => EditorGUILayout.ObjectField(obj, objType, allowSceneObjects);
        public static Object Object(Object obj, Type objType, string label, bool allowSceneObjects = false) => EditorGUILayout.ObjectField(label, obj, objType, allowSceneObjects);
        public static Object Object(Object obj, Type objType, string label, int width, bool allowSceneObjects = false) => EditorGUILayout.ObjectField(label, obj, objType, allowSceneObjects, GUILayout.Width(width));
        public static Object Object(Object obj, Type objType, int width, bool allowSceneObjects = false) => EditorGUILayout.ObjectField(obj, objType, allowSceneObjects, GUILayout.Width(width));

        // Color Select
        public static Color ColorField(Color color, int width) => EditorGUILayout.ColorField(color, GUILayout.Width(width));
        public static Color ColorField(Color color) => EditorGUILayout.ColorField(color);

        // Vector 3 Field
        public static Vector3 Vector3Field(Vector3 value, string label = "") => EditorGUILayout.Vector3Field(label, value);
        public static Vector3 Vector3Field(Vector3 value, int width, string label = "") => EditorGUILayout.Vector3Field(label, value, GUILayout.Width(width));

        // Vector 2 Field
        public static Vector2 Vector2Field(Vector2 value, string label = "") => EditorGUILayout.Vector2Field(label, value);
        public static Vector2 Vector2Field(Vector2 value, int width, string label = "") => EditorGUILayout.Vector2Field(label, value, GUILayout.Width(width));

        // Popup
        public static int Popup(int index, string[] options)
        {
            return EditorGUILayout.Popup(index, options);
        }
        
        public static int Popup(int index, string[] options, int width)
        {
            if (options == null) return default;
            if (options.Length == 0) return default;
            return EditorGUILayout.Popup(index, options, GUILayout.Width(width));
        }
        
        public static int Popup(string label, int index, string[] options)
        {
            return EditorGUILayout.Popup(label, index, options);
        }
        
        public static int Popup(string label, int index, string[] options, int width)
        {
            return EditorGUILayout.Popup(label, index, options, GUILayout.Width(width));
        }
        
        /*
        * ----------------------------------------------------------------------------------------------
        * GUI LAYOUTS
        * ----------------------------------------------------------------------------------------------
        */
        
        // Boxes
        public static void StartVerticalBox() => EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        public static void EndVerticalBox() => EditorGUILayout.EndVertical();
        public static void MessageBox(string content, MessageType messageType = MessageType.None) => EditorGUILayout.HelpBox(content, messageType);

        // Vertical
        public static void StartVertical() => EditorGUILayout.BeginVertical();
        public virtual void EndVertical() => EditorGUILayout.EndVertical();
        
        // Horizontal
        public static void StartRow() => EditorGUILayout.BeginHorizontal();
        public static void EndRow() => EditorGUILayout.EndHorizontal();
        
        // Space
        public static void Space() => EditorGUILayout.Space();
        public static void Space(int height) => EditorGUILayout.Space(height);

        // Foldout Header Group
        public static bool StartFoldoutHeaderGroup(bool value, string text) => EditorGUILayout.BeginFoldoutHeaderGroup(value, text);
        public static void StartFoldoutHeaderGroupSetBool(string boolName, string text) => SetBool(boolName, StartFoldoutHeaderGroup(GetBool(boolName), text));
        public static void EndFoldoutHeaderGroup() => EditorGUILayout.EndFoldoutHeaderGroup();

        /*
        * ----------------------------------------------------------------------------------------------
        * PREFS ETC
        * ----------------------------------------------------------------------------------------------
        */
        
        // Set
        public static void SetBool(string name, bool value) => EditorPrefs.SetBool(name, value);
        public static void SetString(string name, string value) => EditorPrefs.SetString(name, value);
        public static void SetFloat(string name, float value) => EditorPrefs.SetFloat(name, value);
        public static void SetInt(string name, int value) => EditorPrefs.SetInt(name, value);
        
        // Get
        public static bool GetBool(string name) => EditorPrefs.GetBool(name);
        public static string GetString(string name) => EditorPrefs.GetString(name);
        public static float GetFloat(string name) => EditorPrefs.GetFloat(name);
        public static int GetInt(string name) => EditorPrefs.GetInt(name);
        
        // Other
        public static bool HasKey(string name) => EditorPrefs.HasKey(name);

        /*
        * ----------------------------------------------------------------------------------------------
        * UTILITIES
        * ----------------------------------------------------------------------------------------------
        */
        
        // Dialog
        public static bool Dialog(string title, string message, string ok = "Yes", string cancel = "Cancel")
        {
            if (EditorUtility.DisplayDialog(title, message, ok, cancel))
                return true;
            return false;
        }

        // Color
        public static void BackgroundColor(Color color) => GUI.backgroundColor = color;
        public static void ContentColor(Color color) => GUI.contentColor = color;
        public static void ResetColor()
        {
            GUI.backgroundColor = Color.white;
            GUI.contentColor = Color.white;
        }
        
        // Other
        public static void OpenURL(string url) => Application.OpenURL(url);

        public static void ExitGUI() => EditorGUIUtility.ExitGUI();

        public static void IndentPlus() => EditorGUI.indentLevel++;
        public static void IndentMinus() => EditorGUI.indentLevel--;

        // Debug Logs
        public static void Log(string text)
        {
#if UNITY_EDITOR
            Debug.Log(text);
#endif
        }
        
        public static void LogError(string text)
        {
#if UNITY_EDITOR
            Debug.LogError(text);
#endif
        }
        
        public static void LogWarning(string text)
        {
#if UNITY_EDITOR
            Debug.LogWarning(text);
#endif
        }

        /*
        * ----------------------------------------------------------------------------------------------
        * KEYS PRESSED
        * ----------------------------------------------------------------------------------------------
        */

        public static bool KeyAlt => Event.current.alt;
        public static bool KeyShift => Event.current.shift;
    }

    public abstract class SimpleEditor<T> : CustomEditor<T> where T : UnityEngine.Object
    {
        protected T Item;

        private void OnEnable()
        {
            Item = (T) target;
            Init();
        }

        public abstract void Draw(T item);
        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            
            if (!Item) return;
            Draw(Item);
            serializedObject.ApplyModifiedProperties();
        }

        public abstract void Init();
    }
}