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
        if (Build.VERSION.SDK_INT >= 31) {
            splashScreen.setOnExitAnimationListener { it.remove() }
        }
        scene.viewTreeObserver.addOnPreDrawListener(object : ViewTreeObserver.OnPreDrawListener {
            override fun onPreDraw(): Boolean {
                scene.viewTreeObserver.removeOnPreDrawListener(this)
                // Let the compositor present the scene before engine startup
                // occupies the main thread. No user input or artificial intro.
                scene.postDelayed({
                    if (!isFinishing && !isDestroyed) {
                        val next = Intent(this@EntryActivity, MainActivity::class.java).apply {
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
                }, 80)
                return true
            }
        })
    }
}
