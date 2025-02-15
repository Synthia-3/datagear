<#--
 *
 * Copyright 2018 datagear.tech
 *
 * Licensed under the LGPLv3 license:
 * http://www.gnu.org/licenses/lgpl-3.0.html
 *
-->
<#assign ResultDataFormat=statics['org.datagear.analysis.ResultDataFormat']>
<#assign ChartPluginAttributeType=statics['org.datagear.analysis.ChartPluginAttribute$DataType']>
<#include "../include/page_import.ftl">
<#include "../include/html_doctype.ftl">
<html>
<head>
<#include "../include/html_head.ftl">
<title>
	<@spring.message code='module.chart' />
	<#include "../include/html_request_action_suffix.ftl">
	<#include "../include/html_app_name_suffix.ftl">
</title>
</head>
<body class="p-card no-border">
<#include "../include/page_obj.ftl">
<div id="${pid}" class="page page-form horizontal page-form-chart">
	<form id="${pid}form" class="flex flex-column" :class="{readonly: pm.isReadonlyAction}">
		<div class="page-form-content flex-grow-1 px-2 py-1 overflow-y-auto">
			<div class="field grid">
				<label for="${pid}name" class="field-label col-12 mb-2 md:col-3 md:mb-0">
					<@spring.message code='name' />
				</label>
				<div class="field-input col-12 md:col-9">
					<p-inputtext id="${pid}name" v-model="fm.name" type="text" class="input w-full"
						name="name" required maxlength="100" autofocus>
					</p-inputtext>
				</div>
			</div>
			<div class="field grid">
				<label for="${pid}ownerProject" class="field-label col-12 mb-2 md:col-3 md:mb-0">
					<@spring.message code='ownerProject' />
				</label>
				<div class="field-input col-12 md:col-9">
					<div class="p-inputgroup">
						<div class="p-input-icon-right flex-grow-1">
							<i class="pi pi-times cursor-pointer opacity-60" @click="onDeleteAnalysisProject" v-if="!pm.isReadonlyAction">
							</i>
							<p-inputtext id="${pid}ownerProject" v-model="fm.analysisProject.name" type="text" class="input w-full h-full border-noround-right"
								readonly="readonly" name="analysisProject.name" maxlength="200">
							</p-inputtext>
						</div>
						<p-button type="button" label="<@spring.message code='select' />"
							@click="onSelectAnalysisProject" class="p-button-secondary"
							v-if="!pm.isReadonlyAction">
						</p-button>
					</div>
				</div>
			</div>
			<div class="field grid">
				<label for="${pid}htmlChartPlugin" class="field-label col-12 mb-2 md:col-3 md:mb-0">
					<@spring.message code='chartType' />
				</label>
				<div class="field-input col-12 md:col-9">
					<div class="p-inputgroup">
						<div id="${pid}htmlChartPlugin" class="input p-component p-inputtext border-round-left flex align-items-center">
							<div class="flex-grow-0" v-html="formatChartPlugin(fm.htmlChartPlugin)"></div>
							<div class="pl-1" v-if="fm.htmlChartPlugin && fm.htmlChartPlugin.descLabel && fm.htmlChartPlugin.descLabel.value">
								<p-button type="button" icon="pi pi-info-circle"
									@click="onShowChartPluginDesc" class="p-button-secondary p-button-text">
								</p-button>
							</div>
						</div>
						<p-button type="button" label="<@spring.message code='select' />"
							@click="onSelectChartPlugin" v-if="!pm.isReadonlyAction">
						</p-button>
					</div>
		        	<div class="validate-msg">
		        		<input name="htmlChartPlugin" required type="text" class="validate-proxy" />
		        	</div>
				</div>
			</div>
			<div class="field grid">
				<label for="${pid}chartDataSetVOs" class="field-label col-12 mb-2 md:col-3 md:mb-0"
					title="<@spring.message code='chart.cds.desc' />">
					<@spring.message code='module.dataSet' />
				</label>
				<div class="field-input col-12 md:col-9">
					<div id="${pid}chartDataSetVOs" class="chart-datasets input p-component p-inputtext w-full overflow-auto p-2">
						<p-panel v-for="(cds, cdsIdx) in fm.chartDataSetVOs" :key="cdsIdx" :header="cds.dataSet.name" :toggleable="true" class="p-card mb-2 no-panel-border">
							<template #icons>
								<p-button icon="pi pi-arrow-up" class="p-button-sm p-button-secondary p-button-rounded p-button-text mr-2"
									@click="onMoveUpChartDataSet($event, cdsIdx)" v-if="!pm.isReadonlyAction">
								</p-button>
								<p-button icon="pi pi-arrow-down" class="p-button-sm p-button-secondary p-button-rounded p-button-text mr-2"
									@click="onMoveDownChartDataSet($event, cdsIdx)" v-if="!pm.isReadonlyAction">
								</p-button>
								<p-button icon="pi pi-times" class="p-button-sm p-button-secondary p-button-rounded p-button-text p-button-danger mr-5"
									@click="onDeleteChartDataSet($event, cdsIdx)" v-if="!pm.isReadonlyAction">
								</p-button>
							</template>
							<div>
								<p-fieldset v-for="(dp, dpIdx) in cds.dataSet.properties" :key="dpIdx" :legend="formatDspFieldsetName(dp)" class="fieldset-sm mb-3">
									<div class="field grid mb-2">
										<label :for="'${pid}cdspidSign_'+cdsIdx+'_'+dpIdx" class="field-label col-12 mb-2 md:col-3 md:mb-0"
											title="<@spring.message code='chart.cds.dataSign.desc' />">
											<@spring.message code='sign' />
										</label>
										<div class="field-input col-12 md:col-9">
											<div class="p-inputgroup">
												<div :id="'${pid}cdspidSign_'+cdsIdx+'_'+dpIdx"
													class="input p-component p-inputtext border-round-left overflow-auto" style="height:4rem;">
													<p-chip v-for="sign in dp.cdsInfo.signs" :key="sign.name" :label="formatDataSignLabel(sign)" class="mb-2"
														:removable="!pm.isReadonlyAction" @remove="onRemoveDataSign(dp, sign.name)">
													</p-chip>
												</div>
												<p-button type="button" icon="pi pi-plus"
													aria:haspopup="true" aria-controls="${pid}dataSignsPanel"
													@click="onShowDataSignPanel($event, cds, dp)" v-if="!pm.isReadonlyAction">
												</p-button>
											</div>
										</div>
									</div>
									<div class="field grid mb-2">
										<label :for="'${pid}cdspidAlias_'+cdsIdx+'_'+dpIdx" class="field-label col-12 mb-2 md:col-3 md:mb-0"
											title="<@spring.message code='chart.cds.propertyAlias.desc' />">
											<@spring.message code='alias' />
										</label>
										<div class="field-input col-12 md:col-9">
											<p-inputtext :id="'${pid}cdspidAlias_'+cdsIdx+'_'+dpIdx" v-model="dp.cdsInfo.alias" type="text"
												class="input w-full" maxlength="50" :placeholder="dp.label ? dp.label : dp.name">
											</p-inputtext>
										</div>
									</div>
									<div class="field grid mb-2">
										<label :for="'${pid}cdspidSort_'+cdsIdx+'_'+dpIdx" class="field-label col-12 mb-2 md:col-3 md:mb-0"
											title="<@spring.message code='chart.cds.propertyOrder.desc' />">
											<@spring.message code='sort' />
										</label>
										<div class="field-input col-12 md:col-9">
											<p-inputtext :id="'${pid}cdspidSort_'+cdsIdx+'_'+dpIdx" v-model="dp.cdsInfo.order" type="text" class="input w-full" maxlength="50" :placeholder="dpIdx">
											</p-inputtext>
										</div>
									</div>
								</p-fieldset>
							</div>
							<p-divider type="dashed"></p-divider>
							<div class="px-2">
								<div class="field grid mb-2">
									<label :for="'${pid}cdsAlias_'+cdsIdx" class="field-label col-12 mb-2 md:col-3 md:mb-0"
										title="<@spring.message code='chart.cds.alias.desc' />">
										<@spring.message code='alias' />
									</label>
									<div class="field-input col-12 md:col-9">
										<p-inputtext :id="'${pid}cdsAlias_'+cdsIdx" v-model="cds.alias" type="text" class="input w-full" maxlength="50" :placeholder="cds.dataSet.name">
										</p-inputtext>
									</div>
								</div>
								<div class="field grid">
									<label :for="'${pid}cdsAtchm_'+cdsIdx" class="field-label col-12 mb-2 md:col-3 md:mb-0"
										title="<@spring.message code='chart.cds.attachment.desc' />">
										<@spring.message code='attachment' />
									</label>
									<div class="field-input col-12 md:col-9">
										<p-selectbutton :id="'${pid}cdsAtchm_'+cdsIdx" v-model="cds.attachment" :options="pm.booleanOptions"
											option-label="name" option-value="value" class="input w-full">
										</p-selectbutton>
									</div>
								</div>
								<div class="field grid" v-if="cds.dataSet.params.length > 0">
									<label class="field-label col-12 mb-2 md:col-3 md:mb-0"
										title="<@spring.message code='chart.cds.paramValue.desc' />">
										<@spring.message code='parameter' />
									</label>
									<div class="field-input col-12 md:col-9 h-opts">
										<p-button type="button" :label="pm.isReadonlyAction ? '<@spring.message code='view' />' : '<@spring.message code='edit' />'"
											aria:haspopup="true" aria-controls="${pid}paramPanel"
											@click="onShowParamPanel($event, cds)" class="p-button-secondary">
										</p-button>
										<p-button type="button" label="<@spring.message code='clear' />"
											@click="onClearParamValues($event, cds)" class="p-button-secondary p-button-danger"
											v-if="!pm.isReadonlyAction">
										</p-button>
									</div>
								</div>
							</div>
						</p-panel>
					</div>
					<div class="mt-1">
						<div class="flex justify-content-between">
							<div>
								<p-button type="button" label="<@spring.message code='select' />"
									@click="onAddDataSet" v-if="!pm.isReadonlyAction">
								</p-button>
							</div>
							<div>
								<p-button type="button" label="<@spring.message code='dataFormat' />"
									aria:haspopup="true" aria-controls="${pid}dataFormatPanel"
									@click="onShowDataFormatPanel" class="p-button-secondary">
								</p-button>
							</div>
						</div>
					</div>
		        	<div class="validate-msg">
		        		<input name="dspDataSignCheckVal" type="text" class="validate-normalizer" />
		        		<input name="validateDataSetRangeVal" type="text" class="validate-normalizer" />
		        	</div>
				</div>
			</div>
			<div class="field grid">
				<label for="${pid}attrValues" class="field-label col-12 mb-2 md:col-3 md:mb-0"
					title="<@spring.message code='chart.attrValues.desc' />">
					<@spring.message code='chartAttribute' />
				</label>
				<div class="field-input col-12 md:col-9">
					<div class="flex align-items-center">
						<p-button type="button" :label="pm.isReadonlyAction ? '<@spring.message code='view' />' : '<@spring.message code='edit' />'"
							aria:haspopup="true" aria-controls="${pid}attrValuesPanel"
							:disabled="!fm.htmlChartPlugin || !fm.htmlChartPlugin.attributes || fm.htmlChartPlugin.attributes.length==0"
							@click="onShowAttrValuesPanel" class="p-button-secondary mr-2">
						</p-button>
			        	<div class="desc text-color-secondary text-sm" v-if="fm.htmlChartPlugin && (!fm.htmlChartPlugin.attributes || fm.htmlChartPlugin.attributes.length==0)">
			        		<@spring.message code='chart.attrValues.noAttrDefined' />
			        	</div>
		        	</div>
		        	<div class="validate-msg">
		        		<input name="chartAttrValuesCheckVal" type="text" class="validate-normalizer" />
		        	</div>
				</div>
			</div>
			<div class="field grid">
				<label for="${pid}options" class="field-label col-12 mb-2 md:col-3 md:mb-0"
					title="<@spring.message code='chart.options.desc' />">
					<@spring.message code='chartOptions' />
				</label>
				<div class="field-input col-12 md:col-9">
					<div class="flex align-items-center">
						<p-button type="button" :label="pm.isReadonlyAction ? '<@spring.message code='view' />' : '<@spring.message code='edit' />'"
							aria:haspopup="true" aria-controls="${pid}optionsPanel"
							@click="onShowOptionsPanel" class="p-button-secondary mr-2">
						</p-button>
		        	</div>
				</div>
			</div>
			<div class="field grid">
				<label for="${pid}updateInterval" class="field-label col-12 mb-2 md:col-3 md:mb-0"
					title="<@spring.message code='chart.updateInterval.desc' />">
					<@spring.message code='updateInterval' />
				</label>
				<div class="field-input col-12 md:col-9">
					<div class="flex align-content-center">
						<div class="mr-2">
							<p-selectbutton v-model="pm.updateIntervalType" :options="pm.updateIntervalTypeOptions"
								option-label="name" option-value="value" @change="onUpdateIntervalTypeChange">
							</p-selectbutton>
						</div>
						<div class="mr-2" v-if="pm.updateIntervalType == 'interval'">
							<div class="p-inputgroup">
								<p-inputtext id="${pid}updateInterval" v-model="fm.updateInterval" type="text" class="input"
									name="updateInterval" required maxlength="10">
								</p-inputtext>
								<span class="p-inputgroup-addon"><@spring.message code='millisecond' /></span>
							</div>
						</div>
						<div class="flex align-items-center" v-if="pm.updateIntervalType == 'interval'">
							<small class="text-color-secondary"><@spring.message code='chart.updateIntervalValue.desc' /></small>
						</div>
					</div>
				</div>
			</div>
		</div>
		<div class="page-form-foot flex-grow-0 pt-3 text-center h-opts">
			<p-button type="submit" label="<@spring.message code='save' />"></p-button>
			<p-button type="button" label="<@spring.message code='saveAndShow' />" @click="onSaveAndShow"></p-button>
		</div>
	</form>
	<p-overlaypanel ref="${pid}dataSignsPanelEle" append-to="body"
		:show-close-icon="false" id="${pid}dataSignsPanel">
		<div class="pb-2">
			<label class="text-lg font-bold">
				<@spring.message code='dataSign' />
			</label>
		</div>
		<div class="panel-content-size-xs-mwh overflow-auto p-2">
			<div v-for="ds in pm.chartPluginDataSigns" :key="ds.name" class="mb-2">
				<div class="p-inputgroup">
					<p-button type="button" :label="formatDataSignLabel(ds)" icon="pi pi-plus"
						@click="onAddDataSign($event, ds)">
					</p-button>
					<p-button type="button" icon="pi pi-info-circle"
						aria:haspopup="true" aria-controls="${pid}dataSignDetailPanel"
						@click="onShowDataSignDetail($event, ds)" @mouseover="onUpdateDataSignDetailPanel($event, ds)">
					</p-button>
				</div>
			</div>
		</div>
	</p-overlaypanel>
	<p-overlaypanel ref="${pid}dataSignDetailPanelEle" append-to="body" id="${pid}dataSignDetailPanel"
		@show="onDataSignDetailPanelShow" @hide="onDataSignDetailPanelHide">
		<div class="pb-2">
			<label class="text-lg font-bold">
				<@spring.message code='desc' />
			</label>
		</div>
		<div class="panel-content-size-xxs flex flex-column p-2">
			<div class="flex-grow-0 font-bold">
				{{pm.dataSignDetail.label}}
			</div>
			<div class="flex-grow-1 overflow-auto p-3">
				{{pm.dataSignDetail.detail}}
			</div>
		</div>
	</p-overlaypanel>
	<p-overlaypanel ref="${pid}paramPanelEle" append-to="body"
		:show-close-icon="false" @show="onParamPanelShow" id="${pid}paramPanel" class="dataset-paramvalue-panel">
		<div class="pb-2">
			<label class="text-lg font-bold">
				<@spring.message code='parameter' />
			</label>
		</div>
		<div class="paramvalue-form-wrapper panel-content-size-sm overflow-auto p-2"></div>
	</p-overlaypanel>
	<p-overlaypanel ref="${pid}dataFormatPanelEle" append-to="body"
		:show-close-icon="false" id="${pid}dataFormatPanel">
		<div class="pb-2">
			<label class="text-lg font-bold" title="<@spring.message code='chart.rdf.desc' />">
				<@spring.message code='dataFormat' />
			</label>
		</div>
		<div class="panel-content-size-xs overflow-auto p-2">
			<div class="field grid">
				<label for="${pid}rdfEnabled" class="field-label col-12 mb-2"
					title="<@spring.message code='chart.rdf.enabled.desc' />">
					<@spring.message code='isEnable' />
				</label>
				<div class="field-input col-12">
					<p-selectbutton id="${pid}rdfEnabled" v-model="pm.enableResultDataFormat" :options="pm.booleanOptions"
						option-label="name" option-value="value" class="input w-full">
					</p-selectbutton>
				</div>
			</div>
			<div class="field grid" v-if="pm.enableResultDataFormat">
				<label for="${pid}rdfDateType" class="field-label col-12 mb-2">
					<@spring.message code='dateType' />
				</label>
				<div class="field-input col-12">
					<p-selectbutton id="${pid}rdfDateType" v-model="pm.resultDataFormat.dateType" :options="pm.dateOrTimeTypeOptions"
						option-label="name" option-value="value" class="input w-full">
					</p-selectbutton>
				</div>
			</div>
			<div class="field grid" v-if="pm.enableResultDataFormat">
				<label for="${pid}rdfDateFormat" class="field-label col-12 mb-2"
					title="<@spring.message code='chart.rdf.dateFormat.desc' />">
					<@spring.message code='dateFormat' />
				</label>
				<div class="field-input col-12">
					<p-inputtext id="${pid}rdfDateFormat" v-model="pm.resultDataFormat.dateFormat" type="text"
						class="input w-full" maxlength="100">
					</p-inputtext>
				</div>
			</div>
			<div class="field grid" v-if="pm.enableResultDataFormat">
				<label for="${pid}rdfTimeType" class="field-label col-12 mb-2">
					<@spring.message code='timeType' />
				</label>
				<div class="field-input col-12">
					<p-selectbutton id="${pid}rdfTimeType" v-model="pm.resultDataFormat.timeType" :options="pm.dateOrTimeTypeOptions"
						option-label="name" option-value="value" class="input w-full">
					</p-selectbutton>
				</div>
			</div>
			<div class="field grid" v-if="pm.enableResultDataFormat">
				<label for="${pid}rdfTimeFormat" class="field-label col-12 mb-2"
					title="<@spring.message code='chart.rdf.timeFormat.desc' />">
					<@spring.message code='timeFormat' />
				</label>
				<div class="field-input col-12">
					<p-inputtext id="${pid}rdfTimeFormat" v-model="pm.resultDataFormat.timeFormat" type="text"
						class="input w-full" maxlength="100">
					</p-inputtext>
				</div>
			</div>
			<div class="field grid" v-if="pm.enableResultDataFormat">
				<label for="${pid}rdfTimestampType" class="field-label col-12 mb-2">
					<@spring.message code='datetimeType' />
				</label>
				<div class="field-input col-12">
					<p-selectbutton id="${pid}rdfTimestampType" v-model="pm.resultDataFormat.timestampType" :options="pm.dateOrTimeTypeOptions"
						option-label="name" option-value="value" class="input w-full">
					</p-selectbutton>
				</div>
			</div>
			<div class="field grid" v-if="pm.enableResultDataFormat">
				<label for="${pid}rdfTimestampFormat" class="field-label col-12 mb-2"
					title="<@spring.message code='chart.rdf.timestampFormat.desc' />">
					<@spring.message code='datetimeFormat' />
				</label>
				<div class="field-input col-12">
					<p-inputtext id="${pid}rdfTimestampFormat" v-model="pm.resultDataFormat.timestampFormat" type="text"
						class="input w-full" maxlength="100">
					</p-inputtext>
				</div>
			</div>
		</div>
	</p-overlaypanel>
	<p-overlaypanel ref="${pid}htmlChartPluginDescEle" append-to="body" id="${pid}htmlChartPluginDesc">
		<div class="pb-2">
			<label class="text-lg font-bold">
				<@spring.message code='desc' />
			</label>
		</div>
		<div class="panel-content-size-xxs overflow-auto flex flex-column p-2">
			<div v-html="formatChartPluginDesc(fm.htmlChartPlugin)"></div>
		</div>
	</p-overlaypanel>
	<p-overlaypanel ref="${pid}attrValuesPanelEle" append-to="body" id="${pid}attrValuesPanel" @show="onAttrValuesPanelShow">
		<div class="pb-2">
			<label class="text-lg font-bold">
				<@spring.message code='chartAttribute' />
			</label>
		</div>
		<div class="page page-form chart-form-chart-attr-values">
			<#include "include/chart_attr_values_form.ftl">
		</div>
	</p-overlaypanel>
	<p-overlaypanel ref="${pid}optionsPanelEle" append-to="body" id="${pid}optionsPanel" @show="onOptionsPanelShow">
		<div class="pb-2">
			<label class="text-lg font-bold">
				<@spring.message code='chartOptions' />
			</label>
		</div>
		<div class="page page-form">
			<form id="${pid}optionsForm" class="flex flex-column" :class="{readonly: pm.isReadonlyAction}">
				<div class="page-form-content flex-grow-1 px-2 py-1 overflow-y-auto">
					<div class="field grid">
						<div class="field-input col-12">
							<div id="${pid}optionsContent" class="code-editor-wrapper input p-component p-inputtext panel-content-size-xxs">
								<div id="${pid}optionsContentCodeEditor" class="code-editor"></div>
							</div>
				        	<div class="desc text-color-secondary">
				        		<small><@spring.message code='chartOptions.formatDesc' /></small>
				        	</div>
						</div>
					</div>
				</div>
				<div class="page-form-foot flex-grow-0 pt-3 text-center h-opts">
					<p-button type="submit" label="<@spring.message code='confirm' />"></p-button>
				</div>
			</form>
		</div>
	</p-overlaypanel>
</div>
<#include "../include/page_form.ftl">
<#include "../include/page_simple_form.ftl">
<#include "../include/page_boolean_options.ftl">
<#include "../include/page_code_editor.ftl">
<script>
(function(po)
{
	po.submitUrl = "/chart/"+po.submitAction;
	
	po.inSaveAndShowAction = function(val)
	{
		if(val === undefined)
			return (po._inSaveAndShowAction == true);
		
		po._inSaveAndShowAction = val;
	};
	
	po.beforeSubmitForm = function(action)
	{
		var data = action.options.data;
		po.unmergeChartCdss(data);
		
		var cdss = (data.chartDataSetVOs || []);
		$.each(cdss, function(idx, cds)
		{
			cds.summaryDataSetEntity = cds.dataSet;
			cds.dataSet = undefined;
		});
		
		//这里必须整理属性值，因为存在切换图表类型而不编辑图表属性的情况
		var cpas = po.trimChartPluginAttributes(data.htmlChartPlugin ? data.htmlChartPlugin.attributes : null);
		data.attrValues = po.trimChartAttrValues(data.attrValues, cpas);
		
		var pm = po.vuePageModel();
		if(pm.enableResultDataFormat)
			data.resultDataFormat = po.vueRaw(pm.resultDataFormat);
		else
			data.resultDataFormat = undefined;
		
		action.options.saveAndShowAction = po.inSaveAndShowAction();
	};
	
	po.validateChartDataSetDataSign = function(chart)
	{
		var chartPlugin = chart.htmlChartPlugin;
		var chartDataSets = (chart.chartDataSetVOs || []);
		var dataSigns = (chartPlugin ? (chartPlugin.dataSigns || []) : []);
		
		if(!dataSigns)
			return true;
		
		var requiredSigns = [];
		
		$.each(dataSigns, function(idx, dataSign)
		{
			if(dataSign.required == true)
				requiredSigns.push(dataSign);
		});
		
		for(var i=0; i<chartDataSets.length; i++)
		{
			var chartDataSet = chartDataSets[i];
			
			if(chartDataSet.attachment == true)
				continue;
			
			var properties = (chartDataSet.dataSet.properties || []);
			
			for(var j=0; j<requiredSigns.length; j++)
			{
				var requiredSign = requiredSigns[j];
				var contains = false;
				
				for(var k=0; k<properties.length; k++)
				{
					var property = properties[k];
					var signs = (property.cdsInfo ? (property.cdsInfo.signs || []) : []);
					
					if($.inArrayById(signs, requiredSign.name, "name") > -1)
					{
						contains = true;
						break;
					}
				}
				
				if(!contains)
				{
					var invalidInfo = { dataSet: chartDataSet.dataSet, dataSign: requiredSign };
					return invalidInfo;
				}
			}
		}
		
		return true;
	};
	
	po.isChartDataSetSigned = function(chartDataSet, dataSign)
	{
		var properties = (chartDataSet.dataSet.properties || []);
		
		for(var i=0; i<properties.length; i++)
		{
			var property = properties[i];
			var signs = (property.cdsInfo ? (property.cdsInfo.signs || []) : []);
			
			if($.inArrayById(signs, dataSign.name, "name") > -1)
				return true;
		}
		
		return false;
	};
	
	po.mergeChartCdss = function(chart)
	{
		var cdss = (chart.chartDataSetVOs || []);
		$.each(cdss, function(idx, cds)
		{
			po.mergeChartDataSet(cds, chart.htmlChartPlugin);
		});
	};

	po.unmergeChartCdss = function(chart)
	{
		var cdss = (chart.chartDataSetVOs || []);
		$.each(cdss, function(idx, cds)
		{
			po.unmergeChartDataSet(cds, chart.htmlChartPlugin);
		});
	};
	
	po.mergeChartDataSet = function(chartDataSet, chartPlugin)
	{
		var dataSet = chartDataSet.dataSet;
		var properties = (dataSet ? dataSet.properties : []);
		var dataSigns = (chartPlugin && chartPlugin.dataSigns ? chartPlugin.dataSigns : []);
		
		$.each(properties, function(idx, property)
		{
			var signs = [];
			
			var propertySigns = (chartDataSet.propertySigns[property.name] || []);
			$.each(propertySigns, function(psIdx, ps)
			{
				var inArrayIdx = $.inArrayById(dataSigns, ps, "name");
				if(inArrayIdx >= 0)
					signs.push(dataSigns[inArrayIdx]);
			});
			
			property.cdsInfo =
			{
				signs: signs,
				alias: chartDataSet.propertyAliases[property.name],
				order: chartDataSet.propertyOrders[property.name]
			};
		});
	};
	
	po.unmergeChartDataSet = function(chartDataSet, chartPlugin)
	{
		var dataSet = chartDataSet.dataSet;
		var properties = (dataSet ? dataSet.properties : []);
		var dataSigns = (chartPlugin && chartPlugin.dataSigns ? chartPlugin.dataSigns : []);
		
		$.each(properties, function(idx, property)
		{
			var cdsInfo = (property.cdsInfo || {});
			var signs = (cdsInfo.signs || []);
			
			var propertySigns = [];
			$.each(signs, function(psIdx, sign)
			{
				var inArrayIdx = $.inArrayById(dataSigns, sign.name, "name");
				if(inArrayIdx >= 0)
					propertySigns.push(sign.name);
			});
			
			if(propertySigns.length > 0)
				chartDataSet.propertySigns[property.name] = propertySigns;
			else
				chartDataSet.propertySigns[property.name] = undefined;
			chartDataSet.propertyAliases[property.name] = cdsInfo.alias;
			chartDataSet.propertyOrders[property.name] = cdsInfo.order;
			
			property.cdsInfo = undefined;
		});
	};
	
	po.formatDataSignLabel = function(dataSign)
	{
		if(dataSign.nameLabel && dataSign.nameLabel.value)
			return dataSign.nameLabel.value + " ("+dataSign.name+")";
		else
			return dataSign.name;
	};

	po.inflateParamPanel = function(chartDataSet)
	{
		var wrapper = $(".paramvalue-form-wrapper", po.elementOfId("${pid}paramPanel", document.body));
		var pm = po.vuePageModel();
		
		if(!chartDataSet.query)
			chartDataSet.query = {};
		
		var formOptions = $.extend(
		{
			submitText: "<@spring.message code='confirm' />",
			yesText: "<@spring.message code='yes' />",
			noText: "<@spring.message code='no' />",
			paramValues: po.vueRaw(chartDataSet.query.paramValues),
			readonly: pm.isReadonlyAction,
			render: function()
			{
				$("select, input[type='text'], textarea", this).addClass("p-inputtext p-component w-full");
				$("button", this).addClass("p-button p-component");
			},
			submit: function()
			{
				var paramValues = chartFactory.chartSetting.getDataSetParamValueObj(this);
				chartDataSet.query.paramValues = paramValues;
				
				po.vueUnref("${pid}paramPanelEle").hide();
			}
		});
		
		chartFactory.chartSetting.removeDatetimePickerRoot();
		wrapper.empty();
		
		var params = $.extend(true, [], po.vueRaw(chartDataSet.dataSet.params));
		chartFactory.chartSetting.renderDataSetParamValueForm(wrapper, params, formOptions);
	};
	
	$.validator.addMethod("dspDataSignRequired", function(chart, element)
	{
		var re = po.validateChartDataSetDataSign(chart);
		
		if(re == true)
		{
			$(element).removeData("invalidMsg");
			return true;
		}
		else
		{
			var msg = $.validator.format("<@spring.message code='chart.checkChartDataSetDataSign.required' />",
						re.dataSet.name, po.formatDataSignLabel(re.dataSign));
			$(element).data("invalidMsg", msg);
			
			return false;
		}
	});

	$.validator.addMethod("validateDataSetRange", function(chart, element)
	{
		var re = true;
		
		var dsr = (chart.htmlChartPlugin ? chart.htmlChartPlugin.dataSetRange : null);
		var cdss = (chart.chartDataSetVOs || []);
		var mainCount = 0;
		var attachmentCount = 0;
		
		$.each(cdss, function(i, cds)
		{
			if(cds.attachment)
				attachmentCount++;
			else
				mainCount++;
		});
		
		var msg = "";
		var minMsg = "<@spring.message code='noLimit' />";
		var maxMsg = "<@spring.message code='noLimit' />";
		
		if(re && dsr && dsr.main)
		{
			if(dsr.main.min != null)
			{
				minMsg = dsr.main.min;
				re = (re ? (mainCount >= dsr.main.min) : false);
			}
			
			if(dsr.main.max != null)
			{
				maxMsg = dsr.main.max;
				re = (re ? (mainCount <= dsr.main.max) : false);
			}
			
			if(!re)
				msg = $.validator.format("<@spring.message code='chart.validateDataSetRange.main' />", minMsg, maxMsg, mainCount);
		}
		
		if(re && dsr && dsr.attachment)
		{
			if(dsr.attachment.min != null)
			{
				minMsg = dsr.attachment.min;
				re = (re ? (attachmentCount >= dsr.attachment.min) : false);
			}
			
			if(dsr.attachment.max != null)
			{
				maxMsg = dsr.attachment.max;
				re = (re ? (attachmentCount <= dsr.attachment.max) : false);
			}
			
			if(!re)
				msg = $.validator.format("<@spring.message code='chart.validateDataSetRange.attachment' />", minMsg, maxMsg, attachmentCount);
		}
		
		if(re)
			$(element).removeData("invalidMsg");
		else
			$(element).data("invalidMsg", msg);
		
		return re;
	});
	
	$.validator.addMethod("chartAttrValuesRequired", function(chart)
	{
		var cpas = (chart.htmlChartPlugin ? chart.htmlChartPlugin.attributes : null);
		return po.validateChartAttrValuesRequired(cpas, chart.attrValues);
	});
	
	var formModel = $.unescapeHtmlForJson(<@writeJson var=formModel />);
	formModel.analysisProject = (formModel.analysisProject == null ? {} : formModel.analysisProject);
	formModel.chartDataSetVOs = (formModel.chartDataSetVOs == null ? [] : formModel.chartDataSetVOs);
	formModel.plugin = undefined;
	formModel.chartDataSets = undefined;
	formModel.attrValues = (formModel.attrValues || {});
	po.mergeChartCdss(formModel);
	
	po.setupForm(formModel,
	{
		success : function(response)
		{
			var fm = po.vueFormModel();
			var chart = response.data;
			
			fm.id = chart.id;
			
			var options = this;
			if(options.saveAndShowAction)
				window.open(po.concatContextPath("/chart/show/"+encodeURIComponent(chart.id)+"/"), "show-chart-"+chart.id);
		}
	},
	{
		rules:
		{
			updateInterval: {"integer": true},
			dspDataSignCheckVal: { "dspDataSignRequired": true },
			validateDataSetRangeVal: { "validateDataSetRange": true },
			chartAttrValuesCheckVal: { "chartAttrValuesRequired": true }
		},
		customNormalizers:
		{
			dspDataSignCheckVal: function()
			{
				return po.vueFormModel();
			},
			validateDataSetRangeVal: function()
			{
				return po.vueFormModel();
			},
			chartAttrValuesCheckVal: function()
			{
				return po.vueFormModel();
			}
		},
		messages:
		{
			dspDataSignCheckVal:
			{
				dspDataSignRequired: function(val, element)
				{
					return $(element).data("invalidMsg");
				}
			},
			validateDataSetRangeVal:
			{
				validateDataSetRange: function(val, element)
				{
					return $(element).data("invalidMsg");
				}
			},
			chartAttrValuesCheckVal: "<@spring.message code='chart.attrValues.required' />"
		}
	});
	
	po.vuePageModel(
	{
		chartPluginDataSigns: (formModel.htmlChartPlugin ? (formModel.htmlChartPlugin.dataSigns || []) : []),
		dataSignDetail: { label: "", detail: "" },
		dataSignDetailShown: false,
		chartDataSetForSign: null,
		dataSetPropertyForSign: null,
		updateIntervalType: (formModel.updateInterval > -1 ? "interval" : "none"),
		updateIntervalTypeOptions:
		[
			{ name: "<@spring.message code='noUpdate' />", value: "none" },
			{ name: "<@spring.message code='interval' />", value: "interval" }
		],
		resultDataFormat: $.unescapeHtmlForJson(<@writeJson var=initResultDataFormat />),
		enableResultDataFormat: ("${enableResultDataFormat?string('true', 'false')}" == "true"),
		dateOrTimeTypeOptions:
		[
			{ name: "<@spring.message code='string' />", value: "${ResultDataFormat.TYPE_STRING}" },
			{ name: "<@spring.message code='number' />", value: "${ResultDataFormat.TYPE_NUMBER}" }
		],
		optionsFormModel: { options: "" }
	});
	
	po.vueRef("${pid}dataSignsPanelEle", null);
	po.vueRef("${pid}dataSignDetailPanelEle", null);
	po.vueRef("${pid}paramPanelEle", null);
	po.vueRef("${pid}dataFormatPanelEle", null);
	po.vueRef("${pid}htmlChartPluginDescEle", null);
	po.vueRef("${pid}attrValuesPanelEle", null);
	po.vueRef("${pid}optionsPanelEle", null);
	
	po.vueMethod(
	{
		formatChartPlugin: function(chartPlugin)
		{
			return $.toChartPluginHtml(chartPlugin, po.contextPath, {justifyContent: "start"});
		},
		
		formatChartPluginDesc: function(chartPlugin)
		{
			if(chartPlugin && chartPlugin.descLabel && chartPlugin.descLabel.value)
				return chartPlugin.descLabel.value;
			else
				return "<@spring.message code='emptyDesc' />";
		},
		
		formatDataSignLabel: function(dataSign)
		{
			return po.formatDataSignLabel(dataSign);
		},
		
		formatDspFieldsetName: function(dataSetProperty)
		{
			return "<@spring.message code='propertyWithColon' />" + dataSetProperty.name;
		},
		
		onDeleteAnalysisProject: function()
		{
			var fm = po.vueFormModel();
			fm.analysisProject = {};
		},
		
		onSelectAnalysisProject: function()
		{
			po.handleOpenSelectAction("/analysisProject/select", function(analysisProject)
			{
				var fm = po.vueFormModel();
				fm.analysisProject = analysisProject;
			});
		},
		
		onSelectChartPlugin: function()
		{
			po.handleOpenSelectAction("/chartPlugin/select", function(plugin)
			{
				var fm = po.vueFormModel();
				fm.htmlChartPlugin = plugin;
				po.unmergeChartCdss(fm);
				po.mergeChartCdss(fm);
				
				var pm = po.vuePageModel();
				pm.chartPluginDataSigns = (plugin.dataSigns || []);
			});
		},
		
		onAddDataSet: function()
		{
			po.handleOpenSelectAction("/dataSet/select?multiple", function(dataSets)
			{
				var data = $.propertyValueParam(dataSets, "id");
				
				po.getJson("/dataSet/getProfileDataSetByIds", data, function(dataSets)
				{
					var fm = po.vueFormModel();
					
					$.each(dataSets, function(idx, dataSet)
					{
						var cds =
						{
							dataSet: dataSet,
							propertySigns: {},
							propertyAliases: {},
							propertyOrders: {},
							attachment: false
						};
						
						po.mergeChartDataSet(cds);
						fm.chartDataSetVOs.push(cds);
					});
				});
			});
		},
		
		onMoveUpChartDataSet: function(e, cdsIdx)
		{
			var fm = po.vueFormModel();
			if(cdsIdx > 0)
			{
				var prev = fm.chartDataSetVOs[cdsIdx - 1];
				fm.chartDataSetVOs[cdsIdx - 1] = fm.chartDataSetVOs[cdsIdx];
				fm.chartDataSetVOs[cdsIdx] = prev;
			}
		},
		
		onMoveDownChartDataSet: function(e, cdsIdx)
		{
			var fm = po.vueFormModel();
			if((cdsIdx + 1) < fm.chartDataSetVOs.length)
			{
				var next = fm.chartDataSetVOs[cdsIdx + 1];
				fm.chartDataSetVOs[cdsIdx + 1] = fm.chartDataSetVOs[cdsIdx];
				fm.chartDataSetVOs[cdsIdx] = next;
			}
		},
		
		onDeleteChartDataSet: function(e, cdsIdx)
		{
			var fm = po.vueFormModel();
			fm.chartDataSetVOs.splice(cdsIdx, 1);
		},
		
		onShowDataSignPanel: function(e, chartDataSet, dataSetProperty)
		{
			var pm = po.vuePageModel();
			
			//直接show会导致面板还停留在上一个元素上
			po.vueUnref("${pid}dataSignsPanelEle").hide();
			po.vueNextTick(function()
			{
				pm.chartDataSetForSign = chartDataSet;
				pm.dataSetPropertyForSign = dataSetProperty;
				
				po.vueUnref("${pid}dataSignsPanelEle").show(e);
			});
		},
		
		onShowDataSignDetail: function(e, dataSign)
		{
			var pm = po.vuePageModel();
			
			//直接show会导致面板还停留在上一个元素上
			po.vueUnref("${pid}dataSignDetailPanelEle").hide();
			po.vueNextTick(function()
			{
				pm.dataSignDetail.label = po.formatDataSignLabel(dataSign);
				pm.dataSignDetail.detail = (dataSign.descLabel ? (dataSign.descLabel.value || "") : "");
				
				po.vueUnref("${pid}dataSignDetailPanelEle").show(e);
			});
		},
		
		onDataSignDetailPanelShow: function(e)
		{
			var pm = po.vuePageModel();
			pm.dataSignDetailShown = true;
		},
		
		onDataSignDetailPanelHide: function(e)
		{
			var pm = po.vuePageModel();
			pm.dataSignDetailShown = false;
		},
		
		onUpdateDataSignDetailPanel: function(e, dataSign)
		{
			var pm = po.vuePageModel();
			if(pm.dataSignDetailShown)
			{
				pm.dataSignDetail.label = po.formatDataSignLabel(dataSign);
				pm.dataSignDetail.detail = (dataSign.descLabel ? (dataSign.descLabel.value || "") : "");
			}
		},
		
		onAddDataSign: function(e, dataSign)
		{
			var pm = po.vuePageModel();
			
			if(pm.chartDataSetForSign && pm.dataSetPropertyForSign)
			{
				if(!dataSign.multiple && po.isChartDataSetSigned(pm.chartDataSetForSign, dataSign))
				{
					var msg = $.validator.format("<@spring.message code='chart.dataSetHasDataSign' />",
							pm.chartDataSetForSign.dataSet.name, po.formatDataSignLabel(dataSign));
					
					$.tipWarn(msg);
					return;
				}
				
				var signs = pm.dataSetPropertyForSign.cdsInfo.signs;
				
				if($.inArrayById(signs, dataSign.name, "name") < 0)
					signs.push(dataSign);
				
				po.vueUnref("${pid}dataSignsPanelEle").hide();
			}
		},
		
		onRemoveDataSign: function(dataSetProperty, dataSigName)
		{
			var signs = dataSetProperty.cdsInfo.signs;
			$.removeById(signs, dataSigName, "name");
		},
		
		onUpdateIntervalTypeChange: function(e)
		{
			var fm = po.vueFormModel();
			var pm = po.vuePageModel();
			
			if(e.value == "none")
			{
				po._updateIntervalBackup = fm.updateInterval;
				fm.updateInterval = -1;
			}
			else if(e.value == "interval")
			{
				if(po._updateIntervalBackup != null && po._updateIntervalBackup > -1)
					fm.updateInterval = po._updateIntervalBackup;
				else
					fm.updateInterval = 1000;
			}
		},
		
		onShowParamPanel: function(e, chartDataSet)
		{
			po._currentChartDataSetForParam = chartDataSet;
			po.vueUnref("${pid}paramPanelEle").toggle(e);
		},
		
		onParamPanelShow: function(e)
		{
			if(po._currentChartDataSetForParam)
				po.inflateParamPanel(po._currentChartDataSetForParam);
		},
		
		onClearParamValues: function(e, chartDataSet)
		{
			chartDataSet.query.paramValues = {};
		},
		
		onShowDataFormatPanel: function(e)
		{
			po.vueUnref("${pid}dataFormatPanelEle").toggle(e);
		},
		
		onShowChartPluginDesc: function(e)
		{
			po.vueUnref("${pid}htmlChartPluginDescEle").toggle(e);
		},
		
		onShowAttrValuesPanel: function(e)
		{
			po.vueUnref("${pid}attrValuesPanelEle").toggle(e);
		},
		
		onAttrValuesPanelShow: function()
		{
			var fm = po.vueFormModel();
			var pm = po.vuePageModel();
			var chartPluginAttrs = po.vueRaw(fm.htmlChartPlugin ? (fm.htmlChartPlugin.attributes || []) : []);
			var attrValues = po.vueRaw(fm.attrValues);
			po.setupChartAttrValuesForm(chartPluginAttrs, attrValues,
			{
				submitHandler: function(avs)
				{
					fm.attrValues = avs;
					po.vueUnref("${pid}attrValuesPanelEle").hide();
				},
				readonly: pm.isReadonlyAction
			});
		},

		onShowOptionsPanel: function(e)
		{
			po.vueUnref("${pid}optionsPanelEle").toggle(e);
		},
		
		onOptionsPanelShow: function()
		{
			var fm = po.vueFormModel();
			var pm = po.vuePageModel();
			var options = po.vueRaw(fm.options);
			
			var form = po.elementOfId("${pid}optionsForm", document.body);
			var codeEditorEle = po.elementOfId("${pid}optionsContentCodeEditor", form);
			
			var editorOptions =
			{
				value: "",
				matchBrackets: true,
				autoCloseBrackets: true,
				mode: {name: "javascript", json: true}
			};
			
			codeEditorEle.empty();
			var codeEditor = po.createCodeEditor(codeEditorEle, editorOptions);
			po.setCodeTextTimeout(codeEditor, (options || ""), true);
			
			po.setupSimpleForm(form, pm.optionsFormModel, function()
			{
				pm.optionsFormModel.options = po.getCodeText(codeEditor);
				fm.options = pm.optionsFormModel.options;
				po.vueUnref("${pid}optionsPanelEle").hide();
			});
		},
		
		onSaveAndShow: function(e)
		{
			try
			{
				po.inSaveAndShowAction(true);
				po.form().submit();
			}
			finally
			{
				po.inSaveAndShowAction(false);
			}
		}
	});
	
	po.vueMount();
})
(${pid});
</script>
</body>
</html>