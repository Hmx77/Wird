package ae.wird.app

import android.os.Build
import android.os.Bundle
import android.graphics.Color
import android.view.ViewGroup
import android.widget.ImageView
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.RenderMode

class MainActivity : FlutterActivity() {
    private var opening: ImageView? = null

    // A TextureView lets Android draw the owned launch scene while Dart starts,
    // rather than holding the Android 12 solid-colour system splash until then.
    override fun getRenderMode(): RenderMode = RenderMode.texture

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val scene = ImageView(this).apply {
            setImageResource(ae.wird.app.R.drawable.wird_launch_scene)
            scaleType = ImageView.ScaleType.CENTER_CROP
            setBackgroundColor(Color.rgb(0, 36, 44))
            importantForAccessibility = android.view.View.IMPORTANT_FOR_ACCESSIBILITY_NO
        }
        opening = scene
        addContentView(scene, ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
        if (Build.VERSION.SDK_INT >= 31) {
            splashScreen.setOnExitAnimationListener { it.remove() }
        }
    }

    override fun onFlutterUiDisplayed() {
        super.onFlutterUiDisplayed()
        opening?.let { (it.parent as? ViewGroup)?.removeView(it) }
        opening = null
    }
}
