package al.brev.readly

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Home-screen widget: kcal left today + streak / estimated kg lost.
 * Data arrives as strings via the home_widget plugin (see WidgetSync on the
 * Flutter side).
 */
class ReadlyWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.readly_widget).apply {
                val kcalLeft = widgetData.getString("kcal_left", null) ?: "—"
                val streak = widgetData.getString("streak_days", null) ?: "0"
                val kgLost = widgetData.getString("kg_lost", null) ?: "0.00"
                setTextViewText(R.id.widget_kcal, "$kcalLeft kcal left")
                setTextViewText(R.id.widget_stats, "🔥 $streak d · −$kgLost kg")

                // Tapping the widget opens the app.
                val launchIntent =
                    context.packageManager.getLaunchIntentForPackage(context.packageName)
                if (launchIntent != null) {
                    val pendingIntent = PendingIntent.getActivity(
                        context,
                        0,
                        launchIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    setOnClickPendingIntent(R.id.widget_root, pendingIntent)
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
