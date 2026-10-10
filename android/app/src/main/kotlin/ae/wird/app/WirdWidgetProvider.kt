package ae.wird.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class WirdWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager,
                          appWidgetIds: IntArray, widgetData: SharedPreferences) {
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
        val savedDay = widgetData.getString("day", "")
        val completed = if (savedDay == today) widgetData.getInt("completed", 0) else 0
        val english = widgetData.getString("language", "ar") == "en"
        val total = widgetData.getInt("total", 0)
        appWidgetIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.wird_widget)
            views.setTextViewText(R.id.progress, if (total > 0) "$completed / $total" else if (english) "Open Wird to begin" else "افتح ورد للبدء")
            views.setTextViewText(R.id.widget_subtitle, if (english) "Today’s progress" else "متابعتك اليوم")
            views.setTextViewText(R.id.date, today)
            val launch = Intent(context, MainActivity::class.java)
            val pending = PendingIntent.getActivity(context, id, launch,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
            views.setOnClickPendingIntent(R.id.widget_root, pending)
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
