package ae.wird.app

import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.view.ViewTreeObserver
import android.widget.FrameLayout
import android.widget.ImageView
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.android.FlutterEngineConfigurator
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener
import io.flutter.plugins.GeneratedPluginRegistrant

/** Keep the real host's native scene visible while its Flutter engine starts. */
class MainActivity : FragmentActivity(), FlutterUiDisplayListener, FlutterEngineConfigurator {
    private var flutter: FlutterFragment? = null
    private var opening: ImageView? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.statusBarColor = Color.TRANSPARENT
        window.navigationBarColor = Color.rgb(0, 36, 44)
        window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_LAYOUT_STABLE or
            View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
        val root = FrameLayout(this)
        val container = FrameLayout(this).apply { id = R.id.wird_flutter_container }
        root.addView(container, FrameLayout.LayoutParams(-1, -1))
        val scene = ImageView(this).apply {
            setImageResource(R.drawable.wird_launch_scene)
            scaleType = ImageView.ScaleType.CENTER_CROP
            contentDescription = "وِرد"
        }
        opening = scene
        root.addView(scene, FrameLayout.LayoutParams(-1, -1))
        setContentView(root)
        flutter = supportFragmentManager.findFragmentByTag("wird_flutter") as? FlutterFragment
        if (flutter != null) {
            if (flutter?.flutterEngine?.renderer?.isDisplayingFlutterUi == true) {
                root.post { onFlutterUiDisplayed() }
            }
            return
        }
        fun startFlutter() {
            if (isFinishing || isDestroyed || supportFragmentManager.isStateSaved || flutter != null) return
            val fragment = FlutterFragment.withNewEngine()
                .renderMode(RenderMode.texture)
                .shouldDelayFirstAndroidViewDraw(false)
                .shouldAttachEngineToActivity(true)
                .shouldAutomaticallyHandleOnBackPressed(true)
                .build<FlutterFragment>()
            flutter = fragment
            supportFragmentManager.beginTransaction()
                .add(R.id.wird_flutter_container, fragment, "wird_flutter")
                .commitNow()
            fragment.onPostResume()
        }
        if (Build.VERSION.SDK_INT >= 29) {
            root.viewTreeObserver.registerFrameCommitCallback { root.post { startFlutter() } }
        } else {
            root.viewTreeObserver.addOnDrawListener(object : ViewTreeObserver.OnDrawListener {
                override fun onDraw() {
                    root.post {
                        root.viewTreeObserver.removeOnDrawListener(this)
                        root.postDelayed({ startFlutter() }, 32)
                    }
                }
            })
        }
    }

    override fun configureFlutterEngine(engine: FlutterEngine) {
        // A custom fragment host must retain every generated app plugin.
        GeneratedPluginRegistrant.registerWith(engine)
    }
    override fun cleanUpFlutterEngine(engine: FlutterEngine) {}

    override fun onFlutterUiDisplayed() {
        opening?.let { (it.parent as? ViewGroup)?.removeView(it) }
        opening = null
    }
    override fun onFlutterUiNoLongerDisplayed() {}
    override fun onPostResume() { super.onPostResume(); flutter?.onPostResume() }
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        flutter?.onNewIntent(intent)
    }
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        flutter?.onActivityResult(requestCode, resultCode, data)
    }
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        flutter?.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }
    override fun onUserLeaveHint() { super.onUserLeaveHint(); flutter?.onUserLeaveHint() }
    override fun onTrimMemory(level: Int) { super.onTrimMemory(level); flutter?.onTrimMemory(level) }
}
