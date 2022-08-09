<#--
 *
 * Copyright 2018 datagear.tech
 *
 * Licensed under the LGPLv3 license:
 * http://www.gnu.org/licenses/lgpl-3.0.html
 *
-->
<#--
看板资源编辑器

依赖：

-->
<p-tabview v-model:active-index="pm.resourceContentTabs.activeIndex"
	:scrollable="true" @tab-change="onResourceContentTabChange"
	@tab-click="onResourceContentTabClick" class="contextmenu-tabview light-tabview"
	:class="{'opacity-0': pm.resourceContentTabs.items.length == 0}">
	<p-tabpanel v-for="tab in pm.resourceContentTabs.items" :key="tab.key" :header="tab.title">
		<template #header>
			<p-button type="button" icon="pi pi-angle-down"
				class="context-menu-btn p-button-xs p-button-secondary p-button-text p-button-rounded"
				@click="onResourceContentTabMenuToggle($event, tab)"
				aria-haspopup="true" aria-controls="${pid}resourceContentTabMenu">
			</p-button>
		</template>
		<div :id="tab.id">
			<div class="flex align-content-center justify-content-between">
				<div>
					<p-selectbutton v-model="tab.editMode" :options="pm.templateEditModeOptions"
						option-label="name" option-value="value" class="text-sm" @change="onChangeEditMode($event, tab)"
						v-if="tab.isTemplate">
					</p-selectbutton>
				</div>
				<div class="flex" v-if="!pm.isReadonlyAction && tab.editMode == 'code'">
					<p-button label="<@spring.message code='insertChart' />" class="p-button-sm" v-if="tab.isTemplate"></p-button>
					<p-menubar :model="pm.codeEditMenuItems" class="light-menubar no-root-icon-menubar border-none pl-2 text-sm z-99">
						<template #end>
							<div class="p-inputgroup pl-2">
								<p-inputtext type="text" v-model="tab.searchCodeKeyword" class="text-sm p-0 px-1" style="width:9rem;" @keydown.enter.prevent="onSearchInCodeEditor($event, tab)"></p-inputtext>
								<p-button type="button" icon="pi pi-search" class="p-button-secondary p-button-sm" @click="onSearchInCodeEditor($event, tab)"></p-button>
							</div>
						</template>
					</p-menubar>
				</div>
				<div class="flex" v-if="!pm.isReadonlyAction && tab.editMode == 'visual'" v-if="tab.isTemplate">
					<p-button label="<@spring.message code='quickExecute' />" class="p-button-sm"></p-button>
					<p-menubar :model="pm.tplVisualEditMenuItems" class="light-menubar no-root-icon-menubar border-none pl-2 text-sm z-99">
					</p-menubar>
				</div>
			</div>
			<div class="pt-1 relative">
				<div class="code-editor-wrapper res-editor-wrapper show-editor p-component p-inputtext p-0 w-full absolute">
					<div :id="resCodeEditorEleId(tab)" class="code-editor"></div>
				</div>
				<div class="visual-editor-wrapper res-editor-wrapper hide-editor p-component p-inputtext p-0 w-full absolute">
					<div class="visual-editor-ele-path-wrapper text-color-secondary text-sm">
						<div class="ele-path white-space-nowrap"></div>
					</div>
					<div class="visual-editor-iframe-wrapper">
						<iframe class="visual-editor-iframe shadow-4 border-none" :id="resVisualEditorEleId(tab)"
							:name="resVisualEditorEleId(tab)" @load="onVisualEditorIframeLoad($event, tab)">
						</iframe>
					</div>
				</div>
			</div>
		</div>
	</p-tabpanel>
</p-tabview>
<p-contextmenu id="${pid}resourceContentTabMenu" ref="${pid}resourceContentTabMenuEle"
	:model="pm.resourceContentTabMenuItems" :popup="true" class="text-sm">
</p-contextmenu>
<script>
(function(po)
{
	po.defaultTemplateName = "${defaultTempalteName}";
	
	po.resContentTabId = function(resName)
	{
		var map = (po.resContentTabIdMap || (po.resContentTabIdMap = {}));
		
		//不直接使用resName作为元素ID，因为resName中可能存在与jquery冲突的字符，比如'$'
		var value = map[resName];
		
		if(value == null)
		{
			value = $.uid("resCntTab");
			map[resName] = value;
		}
		
		return value;
	};
	
	po.resCodeEditorEleId = function(tab)
	{
		return tab.id + "codeEditor";
	};

	po.resVisualEditorEleId = function(tab)
	{
		return tab.id + "visualEditor";
	};
	
	po.toResourceContentTab = function(resName, isTemplate)
	{
		if(isTemplate == null)
		{
			var fm = po.vueFormModel();
			isTemplate = ($.inArray(resName, fm.templates) > -1);
		}
		
		var re =
		{
			id: po.resContentTabId(resName),
			key: resName,
			title: resName,
			editMode: "code",
			resName: resName,
			isTemplate: isTemplate,
			searchCodeKeyword: null
		};
		
		return re;
	};
	
	po.showResourceContentTab = function(resName, isTemplate)
	{
		var pm = po.vuePageModel();
		var items = pm.resourceContentTabs.items;
		var idx = $.inArrayById(items, po.resContentTabId(resName));
		
		if(idx > -1)
			pm.resourceContentTabs.activeIndex = idx;
		else
		{
			var tab = po.toResourceContentTab(resName, isTemplate);
			pm.resourceContentTabs.items.push(tab);
			
			//直接设置activeIndex不会滚动到新加的卡片，所以采用此方案
			po.vueApp().$nextTick(function()
			{
				pm.resourceContentTabs.activeIndex = pm.resourceContentTabs.items.length - 1;
			});
		}
	};
	
	po.loadResourceContentIfNon = function(tab)
	{
		var tabPanel = po.elementOfId(tab.id);
		var loaded = tabPanel.prop("loaded");
		
		if(!loaded && !tabPanel.prop("loading"))
		{
			tabPanel.prop("loading", true);
			
			var fm = po.vueFormModel();
			
			po.ajax("/dashboard/getResourceContent",
			{
				data:
				{
					id: fm.id,
					resourceName: tab.resName
				},
				success: function(response)
				{
					var resourceContent = (response.resourceExists ? response.resourceContent : "");
					if(tab.isTemplate && !resourceContent)
						resourceContent = (response.defaultTemplateContent || "");
					
					po.setResourceContent(tab, resourceContent);
					tabPanel.prop("loaded", true);
				},
				complete: function()
				{
					tabPanel.prop("loading", false);
				}
			});
		}
	};
	
	po.setResourceContent = function(tab, content)
	{
		var tabPanel = po.elementOfId(tab.id);
		var codeEditorEle = po.elementOfId(po.resCodeEditorEleId(tab), tabPanel);
		var codeEditor = codeEditorEle.data("codeEditorInstance");
		
		if(!codeEditor)
		{
			var codeEditorOptions =
			{
				value: content,
				matchBrackets: true,
				matchTags: true,
				autoCloseTags: true,
				autoCloseBrackets: true,
				readOnly: po.isReadonlyAction,
				foldGutter: true,
				gutters: ["CodeMirror-linenumbers", "CodeMirror-foldgutter"],
				mode: po.evalCodeModeByName(tab.resName)
			};
			
			if(tab.isTemplate && !codeEditorOptions.readOnly)
			{
				codeEditorOptions.hintOptions =
				{
					hint: po.codeEditorHintHandler
				};
			}
			
			codeEditor = po.createCodeEditor(codeEditorEle, codeEditorOptions);
			codeEditorEle.data("codeEditorInstance", codeEditor);
			
			if(tab.isTemplate)
			{
				var visualEditorIfm = po.elementOfId(po.resVisualEditorEleId(tab), tabPanel);
				
				var topWindowSize = po.evalTopWindowSize();
				visualEditorIfm.css("width", topWindowSize.width);
				visualEditorIfm.css("height", topWindowSize.height);
				
				po.setVisualEditorIframeScale(visualEditorIfm);
			}
		}
		else
			po.setCodeText(codeEditor, content);
	};

	po.codeEditorHintHandler = function(codeEditor)
	{
		var doc = codeEditor.getDoc();
		var cursor = doc.getCursor();
		var mode = (codeEditor.getModeAt(cursor) || {});
		var token = (codeEditor.getTokenAt(cursor) || {});
		var tokenString = (token ? $.trim(token.string) : "");
		
		//"dg*"的HTML元素属性
		if("xml" == mode.name && "attribute" == token.type && /^dg/i.test(tokenString))
		{
			var myTagToken = po.findPrevTokenOfType(codeEditor, doc, cursor, token, "tag");
			var myCategory = (myTagToken ? myTagToken.string : null);
			
			var completions =
			{
				list: po.findCompletionList(po.codeEditorCompletionsTagAttr, tokenString, myCategory),
				from: CodeMirror.Pos(cursor.line, token.start),
				to: CodeMirror.Pos(cursor.line, token.end)
			};
			
			return completions;
		}
		//javascript函数
		else if("javascript" == mode.name && (tokenString == "." || "property" == token.type))
		{
			var myVarTokenInfo = po.findPrevTokenInfo(codeEditor, doc, cursor, token,
					function(token){ return (token.type == "variable" || token.type == "variable-2"); });
			var myVarToken = (myVarTokenInfo ? myVarTokenInfo.token : null);
			var myCategory = (myVarToken ? myVarToken.string : "");
			
			//无法确定要补全的是看板还是图表对象，所以这里采用：完全匹配变量名，否则就全部提示
			// *dashboard*
			if(/dashboard/i.test(myCategory))
				myCategory = "dashboard";
			// *chart*
			else if(/chart/i.test(myCategory))
				myCategory = "chart";
			else
				myCategory = null;
			
			var completions =
			{
				list: po.findCompletionList(po.codeEditorCompletionsJsFunction, (tokenString == "." ? "" : tokenString), myCategory),
				from: CodeMirror.Pos(cursor.line, (tokenString == "." ? token.start + 1 : token.start)),
				to: CodeMirror.Pos(cursor.line, token.end)
			};
			
			return completions;
		}
	};
	
	po.getEditResourceInfos = function()
	{
		var re = [];
		
		var pm = po.vuePageModel();
		var items = pm.resourceContentTabs.items;
		
		$.each(items, function(idx, item)
		{
			var info = po.getEditResourceInfo(item);
			if(info)
				re.push(info);
		});
		
		return re;
	};
	
	po.getEditResourceInfo = function(tab)
	{
		if($.isTypeNumber(tab))
		{
			var pm = po.vuePageModel();
			var items = pm.resourceContentTabs.items;
			tab = items[tab];
		}
		
		if(tab == null)
			return null;
		
		var info = { name: tab.resName, content: "", isTemplate: tab.isTemplate };
		
		var editorEle = po.elementOfId(po.resCodeEditorEleId(tab));
		var codeEditor = editorEle.data("codeEditorInstance");
		info.content = po.getCodeText(codeEditor);
		
		return info;
	};
	
	po.saveResourceInfo = function(resInfo)
	{
		if(!resInfo || !po.checkPersistedDashboard())
			return;
		
		var fm = po.vueFormModel();
		
		po.post("/dashboard/saveResourceContent",
		{
			id: fm.id,
			resourceName: resInfo.name,
			resourceContent: resInfo.content,
			isTemplate: resInfo.isTemplate
		},
		function(response)
		{
			if(response.data.templatesChanged)
				po.updateTemplateList(response.data.templates);
			
			if(!response.data.resourceExists)
				po.refreshLocalRes();
		});
	};
	
	po.searchInCodeEditor = function(tab)
	{
		var text = tab.searchCodeKeyword;
		
		if(!text)
			return;
		
		var codeEditorEle = po.elementOfId(po.resCodeEditorEleId(tab));
		var codeEditor = codeEditorEle.data("codeEditorInstance");
		
		var prevSearchText = codeEditorEle.data("prevSearchText");
		var cursor = codeEditorEle.data("prevSearchCursor");
		var doc = codeEditor.getDoc();
		
		if(!cursor || text != prevSearchText)
		{
			cursor = codeEditor.getSearchCursor(text);
			codeEditorEle.data("prevSearchCursor", cursor);
			codeEditorEle.data("prevSearchText", text)
		}
		
		codeEditor.focus();
		
		if(cursor.findNext())
			doc.setSelection(cursor.from(), cursor.to());
		else
		{
			//下次从头搜索
			codeEditorEle.data("prevSearchCursor", null);
		}
	};
	
	po.handleChangeEditMode = function(tab)
	{
		var tabPanel = po.elementOfId(tab.id);
		var codeEditorEle = po.elementOfId(po.resCodeEditorEleId(tab), tabPanel);
		var codeEditorWrapper = codeEditorEle.parent();
		var codeEditor = codeEditorEle.data("codeEditorInstance");
		var visualEditorIfm = po.elementOfId(po.resVisualEditorEleId(tab), tabPanel);
		var visualEditorIfmWrapper = visualEditorIfm.parent();
		var visualEditorWrapper = visualEditorIfmWrapper.parent();
		
		if(tab.editMode == "code")
		{
			var changeFlag = codeEditorEle.data("changeFlag");
			//初次由源码模式切换至可视编辑模式后，changeFlag会是1，
			//但此时是不需要同步的，所以这里手动设置为1
			if(changeFlag == null)
				changeFlag = 1;
			
			var dashboardEditor = po.visualDashboardEditor(visualEditorIfm);
			
			//有修改
			if(dashboardEditor && dashboardEditor.isChanged(changeFlag))
			{
				po.setCodeText(codeEditor, dashboardEditor.editedHtml());
				
				visualEditorIfmWrapper.data("changeFlag", codeEditor.changeGeneration());
				codeEditorEle.data("changeFlag", dashboardEditor.changeFlag());
			}
			
			codeEditorWrapper.addClass("show-editor").removeClass("hide-editor");
			visualEditorWrapper.addClass("hide-editor").removeClass("show-editor");
		}
		else
		{
			var changeFlag = visualEditorIfmWrapper.data("changeFlag");
			
			//没有修改
			if(changeFlag != null && codeEditor.isClean(changeFlag))
				;
			else
			{
				//清空iframe后再显示，防止闪屏
				po.iframeDocument(visualEditorIfm).write("");
				
				visualEditorIfmWrapper.data("changeFlag", codeEditor.changeGeneration());
				codeEditorEle.data("changeFlag", null);
				
				po.loadVisualEditorIframe(visualEditorIfm, tab.resName, (po.isReadonlyAction ? "" : po.getCodeText(codeEditor)));
			}
			
			codeEditorWrapper.addClass("hide-editor").removeClass("show-editor");
			visualEditorWrapper.addClass("show-editor").removeClass("hide-editor");
		}
	};
	
	po.initVisualDashboardEditor = function(tab)
	{
		var tabPanel = po.elementOfId(tab.id);
		var visualEditorIfm = po.elementOfId(po.resVisualEditorEleId(tab), tabPanel);
		var visualEditorIfmWrapper = visualEditorIfm.parent();
		var visualEditorWrapper = visualEditorIfmWrapper.parent();
		
		var ifmWindow = po.iframeWindow(visualEditorIfm);
		var dashboardEditor = (ifmWindow && ifmWindow.dashboardFactory ? ifmWindow.dashboardFactory.dashboardEditor : null);
		
		var elePathWrapper = po.element("> .visual-editor-ele-path-wrapper", visualEditorWrapper);
		var elePathEle = po.element("> .ele-path", elePathWrapper);
		elePathEle.empty();
		
		if(dashboardEditor && !dashboardEditor._OVERWRITE_BY_CONTEXT)
		{
			dashboardEditor._OVERWRITE_BY_CONTEXT = true;
			
			dashboardEditor.i18n.insertInsideChartOnChartEleDenied="<@spring.message code='dashboard.opt.tip.insertInsideChartOnChartEleDenied' />";
			dashboardEditor.i18n.selectElementForSetChart="<@spring.message code='dashboard.opt.tip.selectElementForSetChart' />";
			dashboardEditor.i18n.canEditOnlyTextElement="<@spring.message code='dashboard.opt.tip.canOnlyEditTextElement' />";
			dashboardEditor.i18n.selectedElementRequired="<@spring.message code='dashboard.opt.tip.selectedElementRequired' />";
			dashboardEditor.i18n.selectedNotChartElement="<@spring.message code='dashboard.opt.tip.selectedNotChartElement' />";
			dashboardEditor.i18n.noSelectableNextElement="<@spring.message code='dashboard.opt.tip.noSelectableNextElement' />";
			dashboardEditor.i18n.noSelectablePrevElement="<@spring.message code='dashboard.opt.tip.noSelectablePrevElement' />";
			dashboardEditor.i18n.noSelectableChildElement="<@spring.message code='dashboard.opt.tip.noSelectableChildElement' />";
			dashboardEditor.i18n.noSelectableParentElement="<@spring.message code='dashboard.opt.tip.noSelectableParentElement' />";
			dashboardEditor.i18n.imgEleRequired = "<@spring.message code='dashboard.opt.tip.imgEleRequired' />";
			dashboardEditor.i18n.hyperlinkEleRequired = "<@spring.message code='dashboard.opt.tip.hyperlinkEleRequired' />";
			dashboardEditor.i18n.videoEleRequired = "<@spring.message code='dashboard.opt.tip.videoEleRequired' />";
			dashboardEditor.i18n.labelEleRequired = "<@spring.message code='dashboard.opt.tip.labelEleRequired' />";
			dashboardEditor.tipInfo = function(msg)
			{
				$.tipInfo(msg);
			};
			dashboardEditor.clickCallback = function()
			{
				//关闭可能已显示的面板
				po.element().click();
			};
			dashboardEditor.selectElementCallback = function(ele)
			{
				elePathEle.empty();
				var elePath = this.getElementPath(ele);
				
				$.each(elePath, function(i, ep)
				{
					var eleInfo = ep.tagName;
					if(ep.id)
						eleInfo += "#"+ep.id;
					else if(ep.className)
						eleInfo += "."+ep.className;
					
					if(i > 0)
						$("<span class='info-separator p-1 opacity-50' />").text(">").appendTo(elePathEle);
					
					$("<span class='ele-info cursor-pointer' />").text($.truncateIf(eleInfo, "...", ep.tagName.length+17))
						.attr("visualEditId", (ep.visualEditId || "")).attr("title", eleInfo).appendTo(elePathEle);
				});
				
				var elePathWrapperWidth = elePathWrapper.width();
				var elePathEleWidth = elePathEle.outerWidth(true);
				elePathEle.css("margin-left", (elePathEleWidth > elePathWrapperWidth ? (elePathWrapperWidth - elePathEleWidth) : 0)+"px");
			};
			dashboardEditor.deselectElementCallback = function()
			{
				elePathEle.empty();
				visualEditorIfm.data("selectedElementVeId", "");
			};
			dashboardEditor.beforeunloadCallback = function()
			{
				elePathEle.empty();
				//保存编辑HTML、变更状态，用于刷新操作后恢复页面状态
				visualEditorIfm.data("veEditedHtml", this.editedHtml());
				visualEditorIfm.data("veEnableElementBoundary", this.enableElementBoundary());
				visualEditorIfm.data("veChangeFlag", this.changeFlag());
			};
			
			dashboardEditor.defaultInsertChartEleStyle = po.defaultInsertChartEleStyle;
		}
		
		if(dashboardEditor)
		{
			dashboardEditor.enableElementBoundary(visualEditorIfm.data("veEnableElementBoundary"));
			dashboardEditor.changeFlag(visualEditorIfm.data("veChangeFlag"));
			//XXX 这里无法恢复选中状态，因为每次重新加载后可视编辑ID会重新生成
		}
	};
	
	po.visualDashboardEditor = function(visualEditorIfm)
	{
		var ifmWindow = po.iframeWindow(visualEditorIfm);
		var dashboardEditor = (ifmWindow && ifmWindow.dashboardFactory ? ifmWindow.dashboardFactory.dashboardEditor : null);
		
		return dashboardEditor;
	};
	
	po.loadVisualEditorIframe = function(visualEditorIfm, templateName, templateContent)
	{
		var fm = po.vueFormModel();
		
		var form = po.elementOfId("${pid}visualEditorLoadForm");
		form.attr("action", po.showUrl(templateName));
		form.attr("target", visualEditorIfm.attr("name"));
		po.elementOfName("DG_EDIT_TEMPLATE", form).val(po.isReadonlyAction ? "false" : "true");
		po.elementOfName("DG_TEMPLATE_CONTENT", form).val(templateContent);
		
		form.submit();
	};
	
	po.evalTopWindowSize = function()
	{
		var topWindow = window;
		while(topWindow.parent  && topWindow.parent != topWindow)
			topWindow = topWindow.parent;
		
		var size =
		{
			width: $(topWindow).width(),
			height: $(topWindow).height()
		};
		
		return size;
	};
	
	po.iframeWindow = function(iframe)
	{
		iframe = $(iframe)[0];
		return iframe.contentWindow;
	};
	
	po.iframeDocument = function(iframe)
	{
		iframe = $(iframe)[0];
		return (iframe.contentDocument || iframe.contentWindow.document);
	};
	
	//设置可视编辑iframe的尺寸，使其适配父元素尺寸而不会出现滚动条
	po.setVisualEditorIframeScale = function(iframe, scale)
	{
		iframe = $(iframe);
		scale = (scale == null || scale <= 0 ? "auto" : scale);
		
		iframe.data("veIframeScale", scale);
		
		if(scale == "auto")
		{
			var iframeWrapper = iframe.parent();
			var ww = iframeWrapper.innerWidth(), wh = iframeWrapper.innerHeight();
			var iw = iframe.width(), ih = iframe.height();
			
			//下面的计算只有iframe在iframeWrapper中是绝对定位的才准确
			var rightGap = 10, bottomGap = 20;
			var ileft = parseInt(iframe.css("left")), itop = parseInt(iframe.css("top"));
			ww = ww - ileft - rightGap;
			wh = wh - itop - bottomGap;
			
			if(iw <= ww && ih <= wh)
				return;
			
			var scaleX = ww/iw, scaleY = wh/ih;
			scale = Math.min(scaleX, scaleY);
		}
		else
			scale = scale/100;
		
		iframe.css("transform-origin", "0 0");
		iframe.css("transform", "scale("+scale+")");
	};
	
	po.showFirstTemplateContent =function()
	{
		var fm = po.vueFormModel();
		
		if(fm.templates && fm.templates.length > 0)
			po.showResourceContentTab(fm.templates[0], true);
		else
			po.showResourceContentTab(po.defaultTemplateName, true);
	};
	
	po.buildTplVisualInsertMenuItems = function(insertType)
	{
		var items =
		[
			{
				label: "<@spring.message code='gridLayout' />",
				class: "insert-type-" + insertType,
				command: function()
				{
				}
			},
			{
				label: "<@spring.message code='divElement' />",
				class: "insert-type-" + insertType,
				command: function()
				{
				}
			},
			{
				label: "<@spring.message code='textElement' />",
				class: "insert-type-" + insertType,
				command: function()
				{
				}
			},
			{
				label: "<@spring.message code='image' />",
				class: "insert-type-" + insertType,
				command: function()
				{
				}
			},
			{
				label: "<@spring.message code='hyperlink' />",
				class: "insert-type-" + insertType,
				command: function()
				{
				}
			},
			{
				label: "<@spring.message code='video' />",
				class: "insert-type-" + insertType,
				command: function()
				{
				}
			},
			{ separator: true },
			{
				label: "<@spring.message code='chart' />",
				class: "insert-type-" + insertType,
				command: function()
				{
				}
			}
		];
		
		return items;
	};

	po.setupResourceEditor = function()
	{
		var fm = po.vueFormModel();
		var pm = po.vuePageModel();
		
		po.vuePageModel(
		{
			templateEditModeOptions:
			[
				{ name: "<@spring.message code='dashboard.templateEditMode.code' />", value: "code" },
				{ name: "<@spring.message code='dashboard.templateEditMode.visual' />", value: "visual" }
			],
			resourceContentTabs:
			{
				items: [],
				activeIndex: 0
			},
			resourceContentTabMenuItems:
			[
				{
					label: "<@spring.message code='close' />",
					command: function()
					{
						po.tabviewClose(po.vuePageModel().resourceContentTabs, po.resourceContentTabMenuTargetId);
					}
				},
				{
					label: "<@spring.message code='closeOther' />",
					command: function()
					{
						po.tabviewCloseOther(po.vuePageModel().resourceContentTabs, po.resourceContentTabMenuTargetId);
					}
				},
				{
					label: "<@spring.message code='closeRight' />",
					command: function()
					{
						po.tabviewCloseRight(po.vuePageModel().resourceContentTabs, po.resourceContentTabMenuTargetId);
					}
				},
				{
					label: "<@spring.message code='closeLeft' />",
					command: function()
					{
						po.tabviewCloseLeft(po.vuePageModel().resourceContentTabs, po.resourceContentTabMenuTargetId);
					}
				},
				{
					label: "<@spring.message code='closeAll' />",
					command: function()
					{
						po.tabviewCloseAll(po.vuePageModel().resourceContentTabs);
					}
				}
			],
			codeEditMenuItems:
			[
				{
					label: "<@spring.message code='save' />",
					command: function(e)
					{
						var info = po.getEditResourceInfo(pm.resourceContentTabs.activeIndex);
						po.saveResourceInfo(info);
					}
				}
			],
			tplVisualEditMenuItems:
			[
				{
					label: "<@spring.message code='select' />",
					items:
					[
						{
							label: "<@spring.message code='nextElement' />",
							command: function()
							{
							}
						},
						{
							label: "<@spring.message code='prevElement' />",
							command: function()
							{
							}
						},
						{
							label: "<@spring.message code='subElement' />",
							command: function()
							{
							}
						},
						{
							label: "<@spring.message code='parentElement' />",
							command: function()
							{
							}
						},
						{ separator: true },
						{
							label: "<@spring.message code='cancelSelect' />",
							command: function()
							{
							}
						}
					]
				},
				{
					label: "<@spring.message code='insert' />",
					items:
					[
						{ label: "<@spring.message code='outerInsertAfter' />", items: po.buildTplVisualInsertMenuItems("after") },
						{ label: "<@spring.message code='outerInsertBefore' />", items: po.buildTplVisualInsertMenuItems("before") },
						{ label: "<@spring.message code='innerInsertAfter' />", items: po.buildTplVisualInsertMenuItems("append") },
						{ label: "<@spring.message code='innerInsertBefore' />", items: po.buildTplVisualInsertMenuItems("prepend") },
						{ separator: true },
						{ label: "<@spring.message code='bindOrReplaceChart' />" }
					]
				},
				{
					label: "<@spring.message code='edit' />",
					items:
					[
						{ label: "<@spring.message code='globalStyle' />" },
						{ label: "<@spring.message code='globalChartTheme' />" },
						{ label: "<@spring.message code='globalChartOptions' />" },
						{ separator: true },
						{ label: "<@spring.message code='style' />" },
						{ label: "<@spring.message code='chartTheme' />" },
						{ label: "<@spring.message code='chartOptions' />" },
						{ label: "<@spring.message code='elementAttribute' />" },
						{ label: "<@spring.message code='textContent' />" }
					]
				},
				{
					label: "<@spring.message code='delete' />",
					items:
					[
						{ label: "<@spring.message code='deleteElement' />" },
						{ separator: true },
						{ label: "<@spring.message code='unbindChart' />" }
					]
				},
				{
					label: "<@spring.message code='save' />",
					command: function(e)
					{
						var info = po.getEditResourceInfo(pm.resourceContentTabs.activeIndex);
						po.saveResourceInfo(info);
					}
				},
				{
					label: "<@spring.message code='more' />",
					items:
					[
						{
							label: "<@spring.message code='dashboardSize' />",
							command: function()
							{
							}
						},
						{
							label: "<@spring.message code='elementBorderLine' />",
							command: function()
							{
							}
						},
						{
							label: "<@spring.message code='refresh' />",
							command: function()
							{
							}
						}
					]
				}
			]
		});
		
		po.vueMethod(
		{
			onResourceContentTabChange: function()
			{
				
			},
			
			onResourceContentTabMenuToggle: function(e, tab)
			{
				po.resourceContentTabMenuTargetId = tab.id;
				po.vueUnref("${pid}resourceContentTabMenuEle").show(e);
			},
			
			resCodeEditorEleId: function(tab)
			{
				return po.resCodeEditorEleId(tab);
			},
			
			resVisualEditorEleId: function(tab)
			{
				return po.resVisualEditorEleId(tab);
			},
			
			onChangeEditMode: function(e, tab)
			{
				po.handleChangeEditMode(tab);
			},
			
			onSearchInCodeEditor: function(e, tab)
			{
				po.searchInCodeEditor(tab);
			},
			
			onVisualEditorIframeLoad: function(e, tab)
			{
				po.initVisualDashboardEditor(tab);
			}
		});
		
		po.vueRef("${pid}resourceContentTabMenuEle", null);
		
		//po.showResourceContentTab()里不能获取到创建的DOM元素，所以采用此方案
		po.vueWatch(pm.resourceContentTabs, function(oldVal, newVal)
		{
			var items = newVal.items;
			var activeIndex = newVal.activeIndex;
			var activeTab = items[activeIndex];
			
			if(activeTab)
			{
				po.vueApp().$nextTick(function()
				{
					po.loadResourceContentIfNon(activeTab);
				});
			}
		});
	};
})
(${pid});
</script>