/*
 * Copyright 2018 datagear.tech
 *
 * Licensed under the LGPLv3 license:
 * http://www.gnu.org/licenses/lgpl-3.0.html
 */

package org.datagear.analysis.support.html;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import java.io.StringWriter;
import java.io.Writer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.datagear.analysis.ChartDefinition;
import org.datagear.analysis.RenderContext;
import org.datagear.analysis.TemplateDashboardWidgetResManager;
import org.datagear.analysis.support.DefaultRenderContext;
import org.datagear.analysis.support.FileTemplateDashboardWidgetResManager;
import org.datagear.analysis.support.SimpleChartWidgetSource;
import org.datagear.analysis.support.SimpleDashboardThemeSource;
import org.datagear.analysis.support.html.HtmlTplDashboardRenderAttr.DefaultHtmlTitleHandler;
import org.datagear.analysis.support.html.HtmlTplDashboardRenderAttr.WebContext;
import org.datagear.analysis.support.html.HtmlTplDashboardWidgetHtmlRenderer.ChartInfo;
import org.datagear.analysis.support.html.HtmlTplDashboardWidgetHtmlRenderer.DashboardInfo;
import org.datagear.util.IOUtil;
import org.junit.Test;

/**
 * {@linkplain HtmlTplDashboardWidgetHtmlRenderer}单元测试类。
 * 
 * @author datagear@163.com
 *
 */
public class HtmlTplDashboardWidgetHtmlRendererTest
{
	private HtmlTplDashboardWidgetHtmlRenderer renderer;

	private TemplateDashboardWidgetResManager resManager;

	protected static final String TEMPLATE_NAME = "index.html";

	protected static final String IMPORT_CONTENT_JQUERY = "<script type=\"text/javascript\" src=\"jquery.js\"></script>";

	protected static final String IMPORT_CONTENT_UTIL = "<script type=\"text/javascript\" src=\"util.js\"></script>";

	protected static final String IMPORT_CONTENT_THEME = "<link rel=\"stylesheet\" type=\"text/css\" href=\"theme.css\">";

	protected static final String IMPORT_CONTENT_STYLE = "<link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\">";

	public HtmlTplDashboardWidgetHtmlRendererTest() throws Exception
	{
		super();

		HtmlChartPlugin chartPlugin = HtmlChartPluginTest.createHtmlChartPlugin();

		HtmlChartWidget htmlChartWidget = new HtmlChartWidget("chart-widget-01", "chart-widget-01",
				ChartDefinition.EMPTY_CHART_DATA_SET, chartPlugin);

		this.resManager = new FileTemplateDashboardWidgetResManager(
				"src/test/resources/org/datagear/analysis/support/html/htmlTplDashboardWidgets/html");

		this.renderer = new HtmlTplDashboardWidgetHtmlRenderer(new SimpleChartWidgetSource(htmlChartWidget));
	}

	@Test
	public void renderTest() throws Exception
	{
		HtmlTplDashboardWidget dashboardWidget = createHtmlTplDashboardWidget();

		RenderContext renderContext = new DefaultRenderContext();
		StringWriter out = new StringWriter();
		buildHtmlTplDashboardRenderAttr(renderContext, out);

		HtmlTplDashboard dashboard = dashboardWidget.render(renderContext);

		getHtmlWithPrint(out);

		assertEquals(6, dashboard.getCharts().size());
	}

	@Test
	public void renderDashboardTest() throws Throwable
	{
		HtmlTplDashboardWidget dashboardWidget = createHtmlTplDashboardWidget();

		// 看板属性，双引号
		{
			String template = "<html dg-dashboard-var=\"myDashboard\" dg-dashboard-factory=\"myDashboardFactory\" "
					+ " dg-dashboard-unimport=\"jquery\"><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, template);

			DashboardInfo dashboardInfo = this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
					IOUtil.getReader(template), renderAttr);

			String html = getHtmlWithPrint(out);

			assertEquals("myDashboard", dashboardInfo.getDashboardVar());
			assertEquals("myDashboardFactory", dashboardInfo.getDashboardFactoryVar());
			assertEquals("jquery", dashboardInfo.getDashboardUnimport());
			assertFalse(html.contains(IMPORT_CONTENT_JQUERY));
			assertTrue(html.contains(IMPORT_CONTENT_UTIL));
			assertTrue(html.contains(IMPORT_CONTENT_THEME));
			assertTrue(html.contains(IMPORT_CONTENT_STYLE));
			assertTrue(html.contains("var datagearDashboardTmp="));
			assertTrue(html.contains("myDashboardFactory.init(datagearDashboardTmp);"));
			assertTrue(html.contains(this.renderer.getLocalGlobalVarName() + ".myDashboard=datagearDashboardTmp;"));
			assertTrue(html.contains("datagearDashboardTmp.init();"));
			assertTrue(html.contains("datagearDashboardTmp.render();"));
		}

		// 看板属性，无引号
		{
			String template = "<html dg-dashboard-var=myDashboard dg-dashboard-factory=myDashboardFactory "
					+ " dg-dashboard-unimport=jquery><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, template);

			DashboardInfo dashboardInfo = this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
					IOUtil.getReader(template), renderAttr);

			String html = getHtmlWithPrint(out);

			assertEquals("myDashboard", dashboardInfo.getDashboardVar());
			assertEquals("myDashboardFactory", dashboardInfo.getDashboardFactoryVar());
			assertEquals("jquery", dashboardInfo.getDashboardUnimport());
			assertFalse(html.contains(IMPORT_CONTENT_JQUERY));
			assertTrue(html.contains(IMPORT_CONTENT_UTIL));
			assertTrue(html.contains(IMPORT_CONTENT_THEME));
			assertTrue(html.contains(IMPORT_CONTENT_STYLE));
			assertTrue(html.contains("var datagearDashboardTmp"));
			assertTrue(html.contains("myDashboardFactory.init(datagearDashboardTmp);"));
			assertTrue(html.contains(this.renderer.getLocalGlobalVarName() + ".myDashboard=datagearDashboardTmp;"));
		}

		// 看板属性，单引号
		{
			String template = "<html dg-dashboard-var='myDashboard' dg-dashboard-factory='myDashboardFactory' "
					+ " dg-dashboard-unimport='jquery'><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, template);

			DashboardInfo dashboardInfo = this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
					IOUtil.getReader(template), renderAttr);

			String html = getHtmlWithPrint(out);

			assertEquals("myDashboard", dashboardInfo.getDashboardVar());
			assertEquals("myDashboardFactory", dashboardInfo.getDashboardFactoryVar());
			assertEquals("jquery", dashboardInfo.getDashboardUnimport());
			assertFalse(html.contains(IMPORT_CONTENT_JQUERY));
			assertTrue(html.contains(IMPORT_CONTENT_UTIL));
			assertTrue(html.contains(IMPORT_CONTENT_THEME));
			assertTrue(html.contains(IMPORT_CONTENT_STYLE));
			assertTrue(html.contains("var datagearDashboardTmp"));
			assertTrue(html.contains("myDashboardFactory.init(datagearDashboardTmp);"));
			assertTrue(html.contains(this.renderer.getLocalGlobalVarName() + ".myDashboard=datagearDashboardTmp;"));
		}

		// 看板属性，多个导入排除值
		{
			String template = "<html dg-dashboard-var='myDashboard' dg-dashboard-factory='myDashboardFactory' "
					+ " dg-dashboard-unimport='jquery,theme, style'><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, template);

			DashboardInfo dashboardInfo = this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
					IOUtil.getReader(template), renderAttr);

			String html = getHtmlWithPrint(out);

			assertEquals("myDashboard", dashboardInfo.getDashboardVar());
			assertEquals("myDashboardFactory", dashboardInfo.getDashboardFactoryVar());
			assertEquals("jquery,theme, style", dashboardInfo.getDashboardUnimport());
			assertFalse(html.contains(IMPORT_CONTENT_JQUERY));
			assertTrue(html.contains(IMPORT_CONTENT_UTIL));
			assertFalse(html.contains(IMPORT_CONTENT_THEME));
			assertFalse(html.contains(IMPORT_CONTENT_STYLE));
			assertTrue(html.contains("var datagearDashboardTmp"));
			assertTrue(html.contains("myDashboardFactory.init(datagearDashboardTmp);"));
			assertTrue(html.contains(this.renderer.getLocalGlobalVarName() + ".myDashboard=datagearDashboardTmp;"));
		}

		// 看板属性，默认
		{
			String template = "<html><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, template);

			DashboardInfo dashboardInfo = this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
					IOUtil.getReader(template), renderAttr);

			String html = getHtmlWithPrint(out);

			assertNull(dashboardInfo.getDashboardVar());
			assertNull(dashboardInfo.getDashboardFactoryVar());
			assertNull(dashboardInfo.getDashboardUnimport());
			assertTrue(html.contains(IMPORT_CONTENT_JQUERY));
			assertTrue(html.contains(IMPORT_CONTENT_UTIL));
			assertTrue(html.contains(IMPORT_CONTENT_THEME));
			assertTrue(html.contains(IMPORT_CONTENT_STYLE));
			assertTrue(html.contains("var datagearDashboardTmp"));
			assertTrue(html.contains("dashboardFactory.init(datagearDashboardTmp);"));
			assertTrue(html.contains(this.renderer.getLocalGlobalVarName() + ".dashboard=datagearDashboardTmp;"));
		}

		// 图表属性
		{
			String template = "<html><head></head><body>" + HtmlChartPlugin.HTML_NEW_LINE
					+ "<div id=\"element_1\" dg-chart-widget=\"chartwidget_1\"></div>" + HtmlChartPlugin.HTML_NEW_LINE
					+ "<div id='element_2' dg-chart-widget='chartwidget_2'></div>" + HtmlChartPlugin.HTML_NEW_LINE
					+ "<div id=element_3 dg-chart-widget=chartwidget_3></div>" + HtmlChartPlugin.HTML_NEW_LINE
					+ "<div sdf abc def 12345677788 // >"
					//
					+ HtmlChartPlugin.HTML_NEW_LINE + "<div   id=element_4    dg-chart-widget=chartwidget_4    ></div>"
					+ HtmlChartPlugin.HTML_NEW_LINE + "<div   id  =  element_5    dg-chart-widget=  chartwidget_5 />"
					+ HtmlChartPlugin.HTML_NEW_LINE + "<div   id=element_6    dg-chart-widget=chartwidget_6  />"
					+ HtmlChartPlugin.HTML_NEW_LINE + "<div   id=element_7    dg-chart-widget=chartwidget_7  /  >"
					+ HtmlChartPlugin.HTML_NEW_LINE + "<div     dg-chart-widget=chartwidget_8    /  >"
					//
					+ HtmlChartPlugin.HTML_NEW_LINE + "<div     dg-chart-widget=chartwidget_9/>"
					//
					+ HtmlChartPlugin.HTML_NEW_LINE + "<div     dg-chart-widget='' />"
					//
					+ HtmlChartPlugin.HTML_NEW_LINE + "<div     dg-chart-widget=\"\"  />"
					//
					+ HtmlChartPlugin.HTML_NEW_LINE + "</body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, template);

			DashboardInfo dashboardInfo = this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
					IOUtil.getReader(template), renderAttr);

			String html = getHtmlWithPrint(out);

			List<ChartInfo> chartInfos = dashboardInfo.getChartInfos();
			assertEquals(9, chartInfos.size());

			for (int i = 0; i < 7; i++)
			{
				ChartInfo chartInfo = chartInfos.get(i);
				assertEquals("element_" + (i + 1), chartInfo.getElementId());
				assertEquals("chartwidget_" + (i + 1), chartInfo.getWidgetId());
			}

			assertTrue(html.contains("<html><head>"));
			assertTrue(html.contains("</head><body>"));
			assertTrue(html.contains("<div id=\"element_1\" dg-chart-widget=\"chartwidget_1\"></div>"));
			assertTrue(html.contains("<div id='element_2' dg-chart-widget='chartwidget_2'></div>"));
			assertTrue(html.contains("<div id=element_3 dg-chart-widget=chartwidget_3></div>"));
			assertTrue(html.contains("<div sdf abc def 12345677788 // >"));
			assertTrue(html.contains("<div   id=element_4    dg-chart-widget=chartwidget_4    ></div>"));
			assertTrue(html.contains("<div   id  =  element_5    dg-chart-widget=  chartwidget_5 />"));
			assertTrue(html.contains("<div   id=element_6    dg-chart-widget=chartwidget_6  />"));
			assertTrue(html.contains("<div   id=element_7    dg-chart-widget=chartwidget_7  /  >"));
			assertTrue(
					html.contains("<div     dg-chart-widget=chartwidget_8    /   id=\"datagearchartele7\" >"));
			assertTrue(html.contains("<div     dg-chart-widget=chartwidget_9 id=\"datagearchartele8\" />"));
			assertTrue(html.contains("<div     dg-chart-widget='' />"));
			assertTrue(html.contains("<div     dg-chart-widget=\"\"  />"));
			assertTrue(html.contains("</body></html>"));
		}

		// 处理标题
		{
			String template = "<html><head><title>abc</title></head><body><title>sdf</title></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			DefaultHtmlTitleHandler htmlTitleHandler = new DefaultHtmlTitleHandler("-suffix");
			renderAttr.setHtmlTitleHandler(renderContext, htmlTitleHandler);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, template);

			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME, IOUtil.getReader(template),
					renderAttr);

			String html = getHtmlWithPrint(out);

			assertTrue(html.contains("<title>abc-suffix</title></head>"));
			assertTrue(html.contains("<title>sdf</title>"));
		}

		// 处理标题：没有<title></title>标签
		{
			String template = "<html><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			DefaultHtmlTitleHandler htmlTitleHandler = new DefaultHtmlTitleHandler("-suffix");
			renderAttr.setHtmlTitleHandler(renderContext, htmlTitleHandler);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, template);

			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME, IOUtil.getReader(template),
					renderAttr);

			String html = getHtmlWithPrint(out);

			assertTrue(html.contains("<title>-suffix</title></head>"));
		}

		// 处理标题：没有<title></title>标签
		{
			String template = "<html><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			DefaultHtmlTitleHandler htmlTitleHandler = new DefaultHtmlTitleHandler("-suffix", "generated");
			renderAttr.setHtmlTitleHandler(renderContext, htmlTitleHandler);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, template);

			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME, IOUtil.getReader(template),
					renderAttr);

			String html = getHtmlWithPrint(out);

			assertTrue(html.contains("<title>generated</title></head>"));
		}

		// 处理标题：<title/>
		{
			String template = "<html><head><title/></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			DefaultHtmlTitleHandler htmlTitleHandler = new DefaultHtmlTitleHandler("-suffix", "generated");
			renderAttr.setHtmlTitleHandler(renderContext, htmlTitleHandler);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, template);

			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME, IOUtil.getReader(template),
					renderAttr);

			String html = getHtmlWithPrint(out);

			assertTrue(html.contains("<title/><title>generated</title></head>"));
		}

		// 处理标题：没有</title>
		{
			String template = "<html><head><title></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			DefaultHtmlTitleHandler htmlTitleHandler = new DefaultHtmlTitleHandler("-suffix", "generated");
			renderAttr.setHtmlTitleHandler(renderContext, htmlTitleHandler);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, template);

			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME, IOUtil.getReader(template),
					renderAttr);

			String html = getHtmlWithPrint(out);

			assertTrue(html.contains("<title><title>generated</title></head>"));
		}

		// 没有<head></head>
		{
			String template = "<html><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, template);

			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME, IOUtil.getReader(template),
					renderAttr);

			String html = getHtmlWithPrint(out);

			assertTrue(html.contains("<html><body>" + this.renderer.getNewLine() + "<style"));
			assertTrue(html.contains("</script>" + this.renderer.getNewLine() + "</body></html>"));
			assertEquals(1, countOf(html, "<link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\">"));
			assertEquals(1, countOf(html, "datagearDashboardTmp.render();"));
		}

		// 没有<body></body>
		{
			String template = "<html><head></head></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, template);

			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME, IOUtil.getReader(template),
					renderAttr);

			String html = getHtmlWithPrint(out);

			assertTrue(html.contains("<html><head>" + this.renderer.getNewLine() + "<style"));
			assertTrue(html.contains(
					"<link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\"></head></html><script type=\"text/javascript\">"));
			assertEquals(1, countOf(html, "<link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\">"));
			assertEquals(1, countOf(html, "datagearDashboardTmp.render();"));
			assertTrue(html.endsWith("</script>" + renderer.getNewLine()));
		}

		// <html></html>
		{
			String template = "<html></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, template);

			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME, IOUtil.getReader(template),
					renderAttr);

			String html = getHtmlWithPrint(out);

			assertTrue(html.contains("</html>" + this.renderer.getNewLine() + "<style"));
			assertTrue(html.contains(
					"<link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\"><script type=\"text/javascript\">"));
			assertEquals(1, countOf(html, "<link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\">"));
			assertEquals(1, countOf(html, "datagearDashboardTmp.render();"));
			assertTrue(html.endsWith("</script>" + renderer.getNewLine()));
		}
	}
	
	@Test
	public void renderDashboardTestForLoadableChartWidgets() throws Throwable
	{
		HtmlTplDashboardWidget dashboardWidget = createHtmlTplDashboardWidget();

		{
			String template = "<html><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, template);
			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME, IOUtil.getReader(template), renderAttr);

			assertNull(dashboard.getLoadableChartWidgets());
		}
		{
			String template = "<html dg-loadable-chart-widgets=\"all\"><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, template);
			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME, IOUtil.getReader(template), renderAttr);

			assertTrue(dashboard.getLoadableChartWidgets().isPatternAll());
		}
		{
			String template = "<html dg-loadable-chart-widgets='none'><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, template);
			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME, IOUtil.getReader(template), renderAttr);

			assertTrue(dashboard.getLoadableChartWidgets().isPatternNone());
		}
		{
			String template = "<html dg-loadable-chart-widgets='permitted'><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, template);
			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME, IOUtil.getReader(template), renderAttr);

			assertTrue(dashboard.getLoadableChartWidgets().isPatternPermitted());
		}
		{
			String template = "<html dg-loadable-chart-widgets='a-widget-id'><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, template);
			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME, IOUtil.getReader(template), renderAttr);

			assertTrue(dashboard.getLoadableChartWidgets().isPatternList());
			assertTrue(dashboard.getLoadableChartWidgets().getChartWidgetIds().size() == 1);
			assertTrue(dashboard.getLoadableChartWidgets().inList("a-widget-id"));
		}
		{
			String template = "<html dg-loadable-chart-widgets='widget-id-0,widget-id-1'><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, template);
			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME, IOUtil.getReader(template), renderAttr);

			assertTrue(dashboard.getLoadableChartWidgets().isPatternList());
			assertTrue(dashboard.getLoadableChartWidgets().getChartWidgetIds().size() == 2);
			assertTrue(dashboard.getLoadableChartWidgets().inList("widget-id-0"));
			assertTrue(dashboard.getLoadableChartWidgets().inList("widget-id-1"));
		}
		{
			String template = "<html dg-loadable-chart-widgets='widget-id-0, widget-id-1 , widget-id-2 '><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, template);
			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME, IOUtil.getReader(template), renderAttr);

			assertTrue(dashboard.getLoadableChartWidgets().isPatternList());
			assertTrue(dashboard.getLoadableChartWidgets().getChartWidgetIds().size() == 3);
			assertTrue(dashboard.getLoadableChartWidgets().inList("widget-id-0"));
			assertTrue(dashboard.getLoadableChartWidgets().inList("widget-id-1"));
			assertTrue(dashboard.getLoadableChartWidgets().inList("widget-id-2"));
		}
	}

	@SuppressWarnings("deprecation")
	@Test
	public void renderDashboard_dg_dashboard_auto_render() throws Throwable
	{
		HtmlTplDashboardWidget dashboardWidget = createHtmlTplDashboardWidget();

		{
			String template = "<html><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

			DashboardInfo dashboardInfo = this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
					IOUtil.getReader(template), renderAttr);

			String html = getHtmlWithPrint(out);

			assertTrue(dashboardInfo.isDashboardAutoRender());
			assertTrue(html.contains(dashboard.getVarName() + "."+this.renderer.getDashboardRenderFuncName()+"();"));
		}
		
		{
			String template = "<html dg-dashboard-auto-render='true'><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

			DashboardInfo dashboardInfo = this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
					IOUtil.getReader(template), renderAttr);

			String html = getHtmlWithPrint(out);

			assertTrue(dashboardInfo.isDashboardAutoRender());
			assertTrue(html.contains(dashboard.getVarName() + "."+this.renderer.getDashboardRenderFuncName()+"();"));
		}
		
		{
			String template = "<html dg-dashboard-auto-render=''><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

			DashboardInfo dashboardInfo = this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
					IOUtil.getReader(template), renderAttr);

			String html = getHtmlWithPrint(out);

			assertTrue(dashboardInfo.isDashboardAutoRender());
			assertTrue(html.contains(dashboard.getVarName() + "."+this.renderer.getDashboardRenderFuncName()+"();"));
		}
		
		{
			String template = "<html dg-dashboard-auto-render><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

			DashboardInfo dashboardInfo = this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
					IOUtil.getReader(template), renderAttr);

			String html = getHtmlWithPrint(out);

			assertTrue(dashboardInfo.isDashboardAutoRender());
			assertTrue(html.contains(dashboard.getVarName() + "."+this.renderer.getDashboardRenderFuncName()+"();"));
		}
		
		{
			String template = "<html dg-dashboard-auto-render='a'><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

			DashboardInfo dashboardInfo = this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
					IOUtil.getReader(template), renderAttr);

			String html = getHtmlWithPrint(out);

			assertTrue(dashboardInfo.isDashboardAutoRender());
			assertTrue(html.contains(dashboard.getVarName() + "."+this.renderer.getDashboardRenderFuncName()+"();"));
		}
		
		{
			String template = "<html dg-dashboard-auto-render='false'><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

			DashboardInfo dashboardInfo = this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
					IOUtil.getReader(template), renderAttr);

			String html = getHtmlWithPrint(out);

			assertFalse(dashboardInfo.isDashboardAutoRender());
			assertFalse(html.contains(dashboard.getVarName() + "."+this.renderer.getDashboardRenderFuncName()+"();"));
		}
		
		{
			String template = "<html dg-dashboard-auto-render='FaLse'><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

			DashboardInfo dashboardInfo = this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
					IOUtil.getReader(template), renderAttr);

			String html = getHtmlWithPrint(out);

			assertFalse(dashboardInfo.isDashboardAutoRender());
			assertFalse(html.contains(dashboard.getVarName() + "."+this.renderer.getDashboardRenderFuncName()+"();"));
		}
	}

	@Test
	public void renderDashboard_dg_dashboard_code() throws Throwable
	{
		HtmlTplDashboardWidget dashboardWidget = createHtmlTplDashboardWidget();

		{
			String template = "<html dg-dashboard-code><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME, IOUtil.getReader(template),
					renderAttr);

			String html = getHtmlWithPrint(out);

			assertTrue(html.contains(dashboard.getVarName() + ".init();"));
			assertTrue(html.contains(dashboard.getVarName() + ".render();"));
		}

		{
			String template = "<html dg-dashboard-code=\"instance\"><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME, IOUtil.getReader(template),
					renderAttr);

			String html = getHtmlWithPrint(out);

			assertFalse(html.contains(dashboard.getVarName() + ".init();"));
			assertFalse(html.contains(dashboard.getVarName() + ".render();"));
		}

		{
			String template = "<html dg-dashboard-code=\"init\"><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME, IOUtil.getReader(template),
					renderAttr);

			String html = getHtmlWithPrint(out);

			assertTrue(html.contains(dashboard.getVarName() + ".init();"));
			assertFalse(html.contains(dashboard.getVarName() + ".render();"));
		}

		{
			String template = "<html dg-dashboard-code=\"render\"><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME, IOUtil.getReader(template),
					renderAttr);

			String html = getHtmlWithPrint(out);

			assertTrue(html.contains(dashboard.getVarName() + ".init();"));
			assertTrue(html.contains(dashboard.getVarName() + ".render();"));
		}

		{
			String template = "<html dg-dashboard-code=\"abc\"><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME, IOUtil.getReader(template),
					renderAttr);

			String html = getHtmlWithPrint(out);

			assertTrue(html.contains(dashboard.getVarName() + ".init();"));
			assertTrue(html.contains(dashboard.getVarName() + ".render();"));
		}

		{
			String template = "<html dg-dashboard-code=\"render\" dg-dashboard-auto-render=\"false\"><head></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME, IOUtil.getReader(template),
					renderAttr);

			String html = getHtmlWithPrint(out);

			assertTrue(html.contains(dashboard.getVarName() + ".init();"));
			assertTrue(html.contains(dashboard.getVarName() + ".render();"));
		}

		{
			String template = "<html dg-dashboard-code=\"instance\"><head></head><body><script dg-dashboard-code=\"render\"></script></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME, IOUtil.getReader(template),
					renderAttr);

			String html = getHtmlWithPrint(out);

			assertTrue(html.contains(dashboard.getVarName() + ".init();"));
			assertTrue(html.contains(dashboard.getVarName() + ".render();"));
		}

		{
			String template = "<html><head></head><body><script dg-dashboard-code></script></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
					IOUtil.getReader(template), renderAttr);

			String html = getHtmlWithPrint(out);
			String dashboardRenderCode = dashboard.getVarName() + "."+this.renderer.getDashboardRenderFuncName()+"();";
			
			int scriptStartTagEndIdx = html.indexOf("<script dg-dashboard-code>") + "<script dg-dashboard-code>".length();
			int scriptCloseTagIdx = html.indexOf("</script></body>");
			int dashboardRenderCodeIdx = html.indexOf(dashboardRenderCode);
			
			assertTrue(scriptStartTagEndIdx > 0);
			assertTrue(scriptCloseTagIdx > scriptStartTagEndIdx);
			assertTrue(dashboardRenderCodeIdx > scriptStartTagEndIdx);
			assertTrue(dashboardRenderCodeIdx < scriptCloseTagIdx);
			assertTrue(html.indexOf("<script>", scriptStartTagEndIdx) < 0);
			assertEquals(scriptCloseTagIdx, html.indexOf("</script>", scriptStartTagEndIdx));

			assertTrue(html.contains(dashboard.getVarName() + ".init();"));
			assertTrue(html.contains(dashboard.getVarName() + ".render();"));
		}
		
		{
			String template = "<html><head></head><body><script dg-dashboard-code=\"render\"></script></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
					IOUtil.getReader(template), renderAttr);

			String html = getHtmlWithPrint(out);
			String dashboardRenderCode = dashboard.getVarName() + "."+this.renderer.getDashboardRenderFuncName()+"();";
			
			int scriptStartTagEndIdx = html.indexOf("<script dg-dashboard-code=\"render\">") + "<script dg-dashboard-code=\"render\">".length();
			int scriptCloseTagIdx = html.indexOf("</script></body>");
			int dashboardRenderCodeIdx = html.indexOf(dashboardRenderCode);

			assertTrue(scriptStartTagEndIdx > 0);
			assertTrue(scriptCloseTagIdx > scriptStartTagEndIdx);
			assertTrue(dashboardRenderCodeIdx > scriptStartTagEndIdx);
			assertTrue(dashboardRenderCodeIdx < scriptCloseTagIdx);
			assertTrue(html.indexOf("<script>", scriptStartTagEndIdx) < 0);
			assertEquals(scriptCloseTagIdx, html.indexOf("</script>", scriptStartTagEndIdx));

			assertTrue(html.contains(dashboard.getVarName() + ".init();"));
			assertTrue(html.contains(dashboard.getVarName() + ".render();"));
		}
		
		{
			String template = "<html><head></head><body><script dg-dashboard-code=\"init\"></script></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

			DashboardInfo dashboardInfo = this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
					IOUtil.getReader(template), renderAttr);

			String html = getHtmlWithPrint(out);
			String dashboardInitCode = this.renderer.getDashboardFactoryVarElseDft(dashboardInfo.getDashboardFactoryVar()) + ".init("+dashboard.getVarName()+");";
			String dashboardRenderCode = dashboard.getVarName() + "."+this.renderer.getDashboardRenderFuncName()+"();";
			
			int scriptStartTagEndIdx = html.indexOf("<script dg-dashboard-code=\"init\">") + "<script dg-dashboard-code=\"init\">".length();
			int scriptCloseTagIdx = html.indexOf("</script></body>");
			int dashboardInitCodeIdx = html.indexOf(dashboardInitCode);
			int dashboardRenderCodeIdx = html.indexOf(dashboardRenderCode);

			assertTrue(scriptStartTagEndIdx > 0);
			assertTrue(scriptCloseTagIdx > scriptStartTagEndIdx);
			assertTrue(dashboardInitCodeIdx > scriptStartTagEndIdx);
			assertTrue(dashboardInitCodeIdx < scriptCloseTagIdx);
			assertTrue(dashboardRenderCodeIdx < 0);
			assertTrue(html.indexOf("<script>", scriptStartTagEndIdx) < 0);
			assertEquals(scriptCloseTagIdx, html.indexOf("</script>", scriptStartTagEndIdx));

			assertTrue(html.contains(dashboard.getVarName() + ".init();"));
			assertFalse(html.contains(dashboard.getVarName() + ".render();"));
		}
		
		{
			String template = "<html><head></head><body><script dg-dashboard-code=\"instance\"></script></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

			DashboardInfo dashboardInfo = this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
					IOUtil.getReader(template), renderAttr);

			String html = getHtmlWithPrint(out);
			String dashboardInitCode = this.renderer.getDashboardFactoryVarElseDft(
					dashboardInfo.getDashboardFactoryVar()) + ".init(" + dashboard.getVarName() + ");";
			String dashboardRenderCode = dashboard.getVarName() + "." + this.renderer.getDashboardRenderFuncName()
					+ "();";

			int scriptStartTagEndIdx = html.indexOf("<script dg-dashboard-code=\"instance\">")
					+ "<script dg-dashboard-code=\"instance\">".length();
			int scriptCloseTagIdx = html.indexOf("</script></body>");
			int dashboardInitCodeIdx = html.indexOf(dashboardInitCode);
			int dashboardRenderCodeIdx = html.indexOf(dashboardRenderCode);

			assertTrue(scriptStartTagEndIdx > 0);
			assertTrue(scriptCloseTagIdx > scriptStartTagEndIdx);
			assertTrue(dashboardInitCodeIdx > scriptStartTagEndIdx);
			assertTrue(dashboardInitCodeIdx < scriptCloseTagIdx);
			assertTrue(dashboardRenderCodeIdx < 0);
			assertTrue(html.indexOf("<script>", scriptStartTagEndIdx) < 0);
			assertEquals(scriptCloseTagIdx, html.indexOf("</script>", scriptStartTagEndIdx));

			assertFalse(html.contains(dashboard.getVarName() + ".init();"));
			assertFalse(html.contains(dashboard.getVarName() + ".render();"));
		}

		{
			String template = "<html><head></head><body><script dg-dashboard-code=\"abc\"></script></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
					IOUtil.getReader(template), renderAttr);

			String html = getHtmlWithPrint(out);
			String dashboardRenderCode = dashboard.getVarName() + "."+this.renderer.getDashboardRenderFuncName()+"();";
			
			int scriptStartTagEndIdx = html.indexOf("<script dg-dashboard-code=\"abc\">") + "<script dg-dashboard-code=\"abc\">".length();
			int scriptCloseTagIdx = html.indexOf("</script></body>");
			int dashboardRenderCodeIdx = html.indexOf(dashboardRenderCode);

			assertTrue(scriptStartTagEndIdx > 0);
			assertTrue(scriptCloseTagIdx > scriptStartTagEndIdx);
			assertTrue(dashboardRenderCodeIdx > scriptStartTagEndIdx);
			assertTrue(dashboardRenderCodeIdx < scriptCloseTagIdx);
			assertTrue(html.indexOf("<script>", scriptStartTagEndIdx) < 0);
			assertEquals(scriptCloseTagIdx, html.indexOf("</script>", scriptStartTagEndIdx));
		}
		
		{
			String template = "<html><head></head><body><script dg-dashboard-code=\"abc\" /></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
					IOUtil.getReader(template), renderAttr);

			String html = getHtmlWithPrint(out);
			String dashboardRenderCode = dashboard.getVarName() + "."+this.renderer.getDashboardRenderFuncName()+"();";
			
			int scriptStartTagEndIdx = html.indexOf("<script dg-dashboard-code=\"abc\" />") + "<script dg-dashboard-code=\"abc\" />".length();
			int dashboardRenderCodeIdx = html.indexOf(dashboardRenderCode);
			int writeScriptTagIdx = html.indexOf("<script type=\"text/javascript\">", scriptStartTagEndIdx);
			int writeScriptTagEndIdx = html.indexOf("</script>", writeScriptTagIdx);

			assertTrue(scriptStartTagEndIdx > 0);
			assertTrue(dashboardRenderCodeIdx > writeScriptTagIdx);
			assertTrue(dashboardRenderCodeIdx < writeScriptTagEndIdx);
			assertTrue(writeScriptTagIdx >= scriptStartTagEndIdx);
			assertTrue(writeScriptTagEndIdx > 0);
		}
		
		{
			String template = "<html><head></head><body><script dg-dashboard-code=\"abc\"/></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
					IOUtil.getReader(template), renderAttr);

			String html = getHtmlWithPrint(out);
			String dashboardRenderCode = dashboard.getVarName() + "."+this.renderer.getDashboardRenderFuncName()+"();";
			
			int scriptStartTagEndIdx = html.indexOf("<script dg-dashboard-code=\"abc\"/>") + "<script dg-dashboard-code=\"abc\"/>".length();
			int dashboardRenderCodeIdx = html.indexOf(dashboardRenderCode);
			int writeScriptTagIdx = html.indexOf("<script type=\"text/javascript\">", scriptStartTagEndIdx);
			int writeScriptTagEndIdx = html.indexOf("</script>", writeScriptTagIdx);

			assertTrue(scriptStartTagEndIdx > 0);
			assertTrue(dashboardRenderCodeIdx > writeScriptTagIdx);
			assertTrue(dashboardRenderCodeIdx < writeScriptTagEndIdx);
			assertTrue(writeScriptTagIdx >= scriptStartTagEndIdx);
			assertTrue(writeScriptTagEndIdx > 0);
		}
		
		{
			String template = "<html><head></head><body><script dg-dashboard-code=\"\"></script></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

			this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
					IOUtil.getReader(template), renderAttr);

			String html = getHtmlWithPrint(out);
			String dashboardRenderCode = dashboard.getVarName() + "."+this.renderer.getDashboardRenderFuncName()+"();";
			
			int scriptStartTagEndIdx = html.indexOf("<script dg-dashboard-code=\"\">") + "<script dg-dashboard-code=\"\">".length();
			int scriptCloseTagIdx = html.indexOf("</script></body>");
			int dashboardRenderCodeIdx = html.indexOf(dashboardRenderCode);

			assertTrue(scriptStartTagEndIdx > 0);
			assertTrue(scriptCloseTagIdx > scriptStartTagEndIdx);
			assertTrue(dashboardRenderCodeIdx > scriptStartTagEndIdx);
			assertTrue(dashboardRenderCodeIdx < scriptCloseTagIdx);
		}
		
		//<head></head>里的<script dg-dashboard-code></script>忽略
		{
			String template = "<html><head><script dg-dashboard-code></script></head><body></body></html>";

			RenderContext renderContext = new DefaultRenderContext();
			StringWriter out = new StringWriter();
			HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

			HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

			DashboardInfo dashboardInfo = this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
					IOUtil.getReader(template), renderAttr);

			String html = getHtmlWithPrint(out);
			String dashboardInitCode = this.renderer.getDashboardFactoryVarElseDft(dashboardInfo.getDashboardFactoryVar()) + ".init("+dashboard.getVarName()+");";
			String dashboardRenderCode = dashboard.getVarName() + "."+this.renderer.getDashboardRenderFuncName()+"();";
			
			int scriptCloseTagIdx = html.indexOf("</script></head>");
			int bodyStartTagIdx = html.indexOf("<body>");
			int dashboardInitCodeIdx = html.indexOf(dashboardInitCode);
			int dashboardRenderCodeIdx = html.indexOf(dashboardRenderCode);

			assertTrue(dashboardInitCodeIdx > scriptCloseTagIdx);
			assertTrue(dashboardInitCodeIdx > bodyStartTagIdx);
			assertTrue(dashboardRenderCodeIdx > dashboardInitCodeIdx);
		}
		
		//与dg-dashboard-auto-render组合
		{
			{
				String template = "<html dg-dashboard-auto-render=\"true\"><head></head><body><script dg-dashboard-code></script></body></html>";

				RenderContext renderContext = new DefaultRenderContext();
				StringWriter out = new StringWriter();
				HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

				HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

				this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
						IOUtil.getReader(template), renderAttr);

				String html = getHtmlWithPrint(out);
				String dashboardRenderCode = dashboard.getVarName() + "."+this.renderer.getDashboardRenderFuncName()+"();";
				
				int scriptStartTagEndIdx = html.indexOf("<script dg-dashboard-code>") + "<script dg-dashboard-code>".length();
				int scriptCloseTagIdx = html.indexOf("</script></body>");
				int dashboardRenderCodeIdx = html.indexOf(dashboardRenderCode);

				assertTrue(scriptStartTagEndIdx > 0);
				assertTrue(scriptCloseTagIdx > scriptStartTagEndIdx);
				assertTrue(dashboardRenderCodeIdx > scriptStartTagEndIdx);
				assertTrue(dashboardRenderCodeIdx < scriptCloseTagIdx);
			}
			{
				String template = "<html dg-dashboard-auto-render=\"false\"><head></head><body><script dg-dashboard-code></script></body></html>";

				RenderContext renderContext = new DefaultRenderContext();
				StringWriter out = new StringWriter();
				HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

				HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

				DashboardInfo dashboardInfo = this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
						IOUtil.getReader(template), renderAttr);

				String html = getHtmlWithPrint(out);
				String dashboardInitCode = this.renderer.getDashboardFactoryVarElseDft(dashboardInfo.getDashboardFactoryVar()) + ".init("+dashboard.getVarName()+");";
				String dashboardRenderCode = dashboard.getVarName() + "."+this.renderer.getDashboardRenderFuncName()+"();";
				
				int scriptStartTagEndIdx = html.indexOf("<script dg-dashboard-code>") + "<script dg-dashboard-code>".length();
				int scriptCloseTagIdx = html.indexOf("</script></body>");
				int dashboardInitCodeIdx = html.indexOf(dashboardInitCode);
				int dashboardRenderCodeIdx = html.indexOf(dashboardRenderCode);

				assertTrue(scriptStartTagEndIdx > 0);
				assertTrue(scriptCloseTagIdx > scriptStartTagEndIdx);
				assertTrue(dashboardInitCodeIdx > scriptStartTagEndIdx);
				assertTrue(dashboardInitCodeIdx < scriptCloseTagIdx);
				assertTrue(dashboardRenderCodeIdx < 0);
			}
			
			{
				String template = "<html dg-dashboard-auto-render=\"true\"><head></head><body><script dg-dashboard-code=\"init\"></script></body></html>";
	
				RenderContext renderContext = new DefaultRenderContext();
				StringWriter out = new StringWriter();
				HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);
	
				HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);
	
				DashboardInfo dashboardInfo = this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
						IOUtil.getReader(template), renderAttr);
	
				String html = getHtmlWithPrint(out);
				String dashboardInitCode = this.renderer.getDashboardFactoryVarElseDft(dashboardInfo.getDashboardFactoryVar()) + ".init("+dashboard.getVarName()+");";
				String dashboardRenderCode = dashboard.getVarName() + "."+this.renderer.getDashboardRenderFuncName()+"();";
				
				int scriptStartTagEndIdx = html.indexOf("<script dg-dashboard-code=\"init\">") + "<script dg-dashboard-code=\"init\">".length();
				int scriptCloseTagIdx = html.indexOf("</script></body>");
				int dashboardInitCodeIdx = html.indexOf(dashboardInitCode);
				int dashboardRenderCodeIdx = html.indexOf(dashboardRenderCode);

				assertTrue(scriptStartTagEndIdx > 0);
				assertTrue(scriptCloseTagIdx > scriptStartTagEndIdx);
				assertTrue(dashboardInitCodeIdx > scriptStartTagEndIdx);
				assertTrue(dashboardInitCodeIdx < scriptCloseTagIdx);
				assertTrue(dashboardRenderCodeIdx < 0);
			}
			{
				String template = "<html dg-dashboard-auto-render=\"false\"><head></head><body><script dg-dashboard-code=\"init\"></script></body></html>";
	
				RenderContext renderContext = new DefaultRenderContext();
				StringWriter out = new StringWriter();
				HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);
	
				HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);
	
				DashboardInfo dashboardInfo = this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
						IOUtil.getReader(template), renderAttr);
	
				String html = getHtmlWithPrint(out);
				String dashboardInitCode = this.renderer.getDashboardFactoryVarElseDft(dashboardInfo.getDashboardFactoryVar()) + ".init("+dashboard.getVarName()+");";
				String dashboardRenderCode = dashboard.getVarName() + "."+this.renderer.getDashboardRenderFuncName()+"();";
				
				int scriptStartTagEndIdx = html.indexOf("<script dg-dashboard-code=\"init\">") + "<script dg-dashboard-code=\"init\">".length();
				int scriptCloseTagIdx = html.indexOf("</script></body>");
				int dashboardInitCodeIdx = html.indexOf(dashboardInitCode);
				int dashboardRenderCodeIdx = html.indexOf(dashboardRenderCode);

				assertTrue(scriptStartTagEndIdx > 0);
				assertTrue(scriptCloseTagIdx > scriptStartTagEndIdx);
				assertTrue(dashboardInitCodeIdx > scriptStartTagEndIdx);
				assertTrue(dashboardInitCodeIdx < scriptCloseTagIdx);
				assertTrue(dashboardRenderCodeIdx < 0);
			}
			
			{
				String template = "<html dg-dashboard-auto-render=\"true\"><head></head><body><script dg-dashboard-code=\"render\"></script></body></html>";

				RenderContext renderContext = new DefaultRenderContext();
				StringWriter out = new StringWriter();
				HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

				HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

				this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
						IOUtil.getReader(template), renderAttr);

				String html = getHtmlWithPrint(out);
				String dashboardRenderCode = dashboard.getVarName() + "."+this.renderer.getDashboardRenderFuncName()+"();";
				
				int scriptStartTagEndIdx = html.indexOf("<script dg-dashboard-code=\"render\">") + "<script dg-dashboard-code=\"render\">".length();
				int scriptCloseTagIdx = html.indexOf("</script></body>");
				int dashboardRenderCodeIdx = html.indexOf(dashboardRenderCode);

				assertTrue(scriptStartTagEndIdx > 0);
				assertTrue(scriptCloseTagIdx > scriptStartTagEndIdx);
				assertTrue(dashboardRenderCodeIdx > scriptStartTagEndIdx);
				assertTrue(dashboardRenderCodeIdx < scriptCloseTagIdx);
			}
			{
				String template = "<html dg-dashboard-auto-render=\"false\"><head></head><body><script dg-dashboard-code=\"render\"></script></body></html>";

				RenderContext renderContext = new DefaultRenderContext();
				StringWriter out = new StringWriter();
				HtmlTplDashboardRenderAttr renderAttr = buildHtmlTplDashboardRenderAttr(renderContext, out);

				HtmlTplDashboard dashboard = this.renderer.createDashboard(renderContext, dashboardWidget, TEMPLATE_NAME);

				this.renderer.renderDashboard(renderContext, dashboard, TEMPLATE_NAME,
						IOUtil.getReader(template), renderAttr);

				String html = getHtmlWithPrint(out);
				String dashboardRenderCode = dashboard.getVarName() + "."+this.renderer.getDashboardRenderFuncName()+"();";
				
				int scriptStartTagEndIdx = html.indexOf("<script dg-dashboard-code=\"render\">") + "<script dg-dashboard-code=\"render\">".length();
				int scriptCloseTagIdx = html.indexOf("</script></body>");
				int dashboardRenderCodeIdx = html.indexOf(dashboardRenderCode);

				assertTrue(scriptStartTagEndIdx > 0);
				assertTrue(scriptCloseTagIdx > scriptStartTagEndIdx);
				assertTrue(dashboardRenderCodeIdx > scriptStartTagEndIdx);
				assertTrue(dashboardRenderCodeIdx < scriptCloseTagIdx);
			}
		}
	}

	protected HtmlTplDashboardRenderAttr buildHtmlTplDashboardRenderAttr(RenderContext renderContext, Writer out)
	{
		HtmlTplDashboardRenderAttr renderAttr = new HtmlTplDashboardRenderAttr();
		renderAttr.inflate(renderContext, out);
		renderAttr.setWebContext(renderContext, new WebContext(""));
		renderAttr.setDashboardTheme(renderContext, SimpleDashboardThemeSource.THEME_LIGHT);
		renderAttr.setImportList(renderContext, buildImportList());
		
		renderAttr.setIgnoreRenderAttrs(renderContext,
				Arrays.asList(renderAttr.getHtmlWriterName(), renderAttr.getImportListName(),
						renderAttr.getHtmlTitleHandlerName(),
						renderAttr.getIgnoreRenderAttrsName(), HtmlTplDashboardRenderAttr.ATTR_NAME));

		return renderAttr;
	}

	protected List<HtmlTplDashboardImport> buildImportList()
	{
		List<HtmlTplDashboardImport> list = new ArrayList<>();

		list.add(HtmlTplDashboardImport.valueOf("jquery", IMPORT_CONTENT_JQUERY));
		list.add(HtmlTplDashboardImport.valueOf("util", IMPORT_CONTENT_UTIL));
		list.add(HtmlTplDashboardImport.valueOf("theme", IMPORT_CONTENT_THEME));
		list.add(HtmlTplDashboardImport.valueOf("style", IMPORT_CONTENT_STYLE));

		return list;
	}

	protected HtmlTplDashboardWidget createHtmlTplDashboardWidget()
	{
		HtmlTplDashboardWidget dashboardWidget = new HtmlTplDashboardWidget("widget01", TEMPLATE_NAME, this.renderer,
				this.resManager);
		return dashboardWidget;
	}

	protected int countOf(String src, String sub)
	{
		int c = 0;

		int idx = -1;
		while (true)
		{
			idx = src.indexOf(sub, (idx < 0 ? 0 : idx + sub.length()));

			if (idx < 0)
				break;
			else
				c++;
		}

		return c;
	}

	protected String getHtmlWithPrint(StringWriter out)
	{
		String html = out.toString();

		System.out.println(html);
		System.out.println("");
		System.out.println("-----------------------");
		System.out.println("");

		return html;
	}
}
