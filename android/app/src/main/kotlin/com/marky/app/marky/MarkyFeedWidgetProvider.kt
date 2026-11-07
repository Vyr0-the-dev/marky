package com.marky.app.marky

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews

class MarkyFeedWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        updateWidgets(context, appWidgetManager, appWidgetIds)
    }

    companion object {
        private const val prefsName = "FlutterSharedPreferences"
        private const val titleKey = "flutter.marky_widget_title"
        private const val subtitleKey = "flutter.marky_widget_subtitle"
        private const val item1Key = "flutter.marky_widget_item_1"
        private const val item2Key = "flutter.marky_widget_item_2"
        private const val item3Key = "flutter.marky_widget_item_3"

        fun updateAll(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, MarkyFeedWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(component)
            updateWidgets(context, appWidgetManager, appWidgetIds)
        }

        private fun updateWidgets(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetIds: IntArray
        ) {
            val prefs = context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)
            val title = prefs.getString(titleKey, "Marky") ?: "Marky"
            val subtitle = prefs.getString(subtitleKey, "Your links, ready") ?: "Your links, ready"
            val item1 = prefs.getString(item1Key, "Add links to see snippets here")
                ?: "Add links to see snippets here"
            val item2 = prefs.getString(item2Key, "") ?: ""
            val item3 = prefs.getString(item3Key, "") ?: ""

            for (appWidgetId in appWidgetIds) {
                val views = RemoteViews(context.packageName, R.layout.marky_feed_widget)
                views.setTextViewText(R.id.widget_title, title)
                views.setTextViewText(R.id.widget_subtitle, subtitle)

                // Header action buttons
                views.setOnClickPendingIntent(
                    R.id.widget_action_add,
                    openRoutePendingIntent(context, "/add")
                )
                views.setOnClickPendingIntent(
                    R.id.widget_action_search,
                    openRoutePendingIntent(context, "/search")
                )
                views.setOnClickPendingIntent(
                    R.id.widget_root,
                    openRoutePendingIntent(context, "/home")
                )

                // Item cards
                applyItem(
                    views = views,
                    containerId = R.id.widget_item_1_container,
                    titleId = R.id.widget_item_1,
                    subtitleId = R.id.widget_item_1_subtitle,
                    value = item1,
                    context = context
                )
                applyItem(
                    views = views,
                    containerId = R.id.widget_item_2_container,
                    titleId = R.id.widget_item_2,
                    subtitleId = R.id.widget_item_2_subtitle,
                    value = item2,
                    context = context
                )
                applyItem(
                    views = views,
                    containerId = R.id.widget_item_3_container,
                    titleId = R.id.widget_item_3,
                    subtitleId = R.id.widget_item_3_subtitle,
                    value = item3,
                    context = context
                )

                // Empty state visibility
                val hasAnyItem = item1.isNotBlank() || item2.isNotBlank() || item3.isNotBlank()
                views.setViewVisibility(
                    R.id.widget_empty_text,
                    if (hasAnyItem) View.GONE else View.VISIBLE
                )

                appWidgetManager.updateAppWidget(appWidgetId, views)
            }
        }

        private fun applyItem(
            views: RemoteViews,
            containerId: Int,
            titleId: Int,
            subtitleId: Int,
            value: String,
            context: Context
        ) {
            if (value.isBlank()) {
                views.setViewVisibility(containerId, View.GONE)
                return
            }
            views.setViewVisibility(containerId, View.VISIBLE)
            if (value.contains(" — ")) {
                val parts = value.split(" — ", limit = 2)
                views.setTextViewText(titleId, parts[0].trim())
                views.setTextViewText(subtitleId, parts[1].trim())
                views.setViewVisibility(subtitleId, View.VISIBLE)
            } else {
                views.setTextViewText(titleId, value.trim())
                views.setViewVisibility(subtitleId, View.GONE)
            }
            views.setOnClickPendingIntent(
                containerId,
                openRoutePendingIntent(context, "/home")
            )
        }

        private fun openRoutePendingIntent(context: Context, route: String): PendingIntent {
            val intent = Intent(context, MainActivity::class.java).apply {
                action = MainActivity.openRouteAction
                putExtra(MainActivity.routeExtra, route)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            return PendingIntent.getActivity(
                context,
                route.hashCode(),
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }
    }
}
