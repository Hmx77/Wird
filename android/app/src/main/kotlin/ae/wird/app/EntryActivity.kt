package ae.wird.app

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.ViewTreeObserver
import android.widget.ImageView

/** Draw the owned scene before loading the Flutter engine. Both windows use
 * the same scene, so this is one visual opening, followed by the real home. */
class EntryActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.statusBarColor = Color.TRANSPARENT
        window.navigationBarColor = Color.rgb(0, 36, 44)
        window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_LAYOUT_STABLE or
            View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
        val scene = ImageView(this).apply {
            setImageResource(R.drawable.wird_launch_scene)
            scaleType = ImageView.ScaleType.CENTER_CROP
            contentDescription = "وِرد"
        }
        setContentView(scene)
        fun enterFlutter() {
            if (isFinishing || isDestroyed) return
            val next = Intent(this, MainActivity::class.java).apply {
                action = intent.action
                data = intent.data
                intent.extras?.let { putExtras(it) }
                addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            }
            startActivity(next)
            overridePendingTransition(0, 0)
            finish()
        }
        if (Build.VERSION.SDK_INT >= 29) {
            // Wait for the hardware-rendered native frame to be committed.
            // A pre-draw callback fires too early and can transfer Android's
            // starting window into the Flutter activity before the scene shows.
            scene.viewTreeObserver.registerFrameCommitCallback {
                scene.post { enterFlutter() }
            }
        } else {
            scene.viewTreeObserver.addOnDrawListener(object : ViewTreeObserver.OnDrawListener {
                override fun onDraw() {
                    scene.post {
                        scene.viewTreeObserver.removeOnDrawListener(this)
                        scene.postDelayed({ enterFlutter() }, 80)
                    }
                }
            })
        }
    }
}
