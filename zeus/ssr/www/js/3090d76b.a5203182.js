(window["webpackJsonp"]=window["webpackJsonp"]||[]).push([["3090d76b"],{6620:function(e,t,n){t=e.exports=n("24fb")(!1),t.push([e.i,".section-maxwidth{max-width:992px}",""])},"6a81":function(e,t,n){"use strict";var i=function(){var e=this,t=e.$createElement,n=e._self._c||t;return n("section",{class:e.section.fullwidth?"q-mb-md":"section-maxwidth q-mx-auto q-px-md q-my-md"},[e._t("editor"),n("div",{staticClass:"row wrap q-col-gutter-md"},[e._t("default")],2)],2)},s=[],r={name:"DynamicSection",props:{section:{type:Object,required:!0}}},a=r,l=(n("ee6a"),n("2877")),o=Object(l["a"])(a,i,s,!1,null,null,null);t["a"]=o.exports},8062:function(e,t,n){"use strict";var i=function(){var e=this,t=e.$createElement,n=e._self._c||t;return n("div",{staticClass:"no-shadow",class:e.elementClass},[n("q-card",{class:e.card?"overflow-hidden rounded-borders":"no-shadow"},[e._t("editor"),n("div",{class:{"cursor-pointer":e.hasLink},on:{click:e.handleClick}},[e.$i18n(e.element,"image")?n("q-img",{attrs:{src:e.$img.src(e.$i18n(e.element,"image").image_id),srcset:e.$img.srcset(e.$i18n(e.element,"image")),sizes:e.imageSizes,placeholder:e.$i18n(e.element,"image").placeholder}},[e.$i18n(e.element,"caption")?n("div",{staticClass:"absolute-bottom text-subtitle2 text-center"},[e._v("\n          "+e._s(e.$i18n(e.element,"caption"))+"\n          "),e.hasLink?n("q-icon",{attrs:{name:"mdi-forward"}}):e._e()],1):e._e()]):e._e(),e.$i18n(e.element,"title")||e.$i18n(e.element,"subtitle")?n("q-card-section",[e.$i18n(e.element,"title")?n("div",{staticClass:"text-h6 text-primary"},[e._v(e._s(e.$i18n(e.element,"title")))]):e._e(),e.$i18n(e.element,"subtitle")?n("div",{staticClass:"text-subtitle2 text-accent"},[e._v(e._s(e.$i18n(e.element,"subtitle")))]):e._e()]):e._e(),e.$i18n(e.element,"body")?n("q-card-section",[n("div",{domProps:{innerHTML:e._s(e.$i18n(e.element,"body"))}})]):e._e()],1)],2)],1)},s=[],r=(n("4917"),n("f3e3")),a=n.n(r),l=n("0967"),o=n("2b0e"),c=function(e,t){var n=window.open;if(!0===l["a"].is.cordova){if(void 0!==cordova&&void 0!==cordova.InAppBrowser&&void 0!==cordova.InAppBrowser.open)n=cordova.InAppBrowser.open;else if(void 0!==navigator&&void 0!==navigator.app)return navigator.app.loadUrl(e,{openExternal:!0})}else if(void 0!==o["a"].prototype.$q.electron)return o["a"].prototype.$q.electron.shell.openExternal(e);var i=n(e,"_blank");if(i)return i.focus(),i;t&&t()},u={name:"DynamicElement",props:{card:{type:Boolean,default:!0},element:{type:Object,required:!0}},computed:{hasLink:function(){return null!==this.element.internal_link||(null!==this.element.external_link||null!==this.element.listing_link)},imageSizes:function(){switch(this.element.size_id){case"xl":return"100vw";case"lg":return"80vw";case"md":return"50vw";case"sm":return"33vw";case"xs":return"25vw";default:return""}},elementClass:function(){switch(this.element.size_id){case"xl":return"col-12";case"lg":return"col-12 col-md-8";case"md":return"col-12 col-sm-6";case"sm":return"col-12 col-sm-6 col-md-4";case"xs":return"col-6 col-sm-3";default:return""}}},methods:{handleClick:function(){if(null!==this.element.internal_link){var e=this.$route.fullPath.match(/^\/website\/(editor|preview)/),t=a()(e,2),n=t[1];this.$router.push("/website/".concat(n,"/").concat(this.element.internal_link))}else null!==this.element.external_link?c(this.element.external_link):null!==this.element.listing_link&&this.$router.push("/listing/".concat(this.element.listing_link))}}},m=u,d=n("2877"),p=Object(d["a"])(m,i,s,!1,null,null,null);t["a"]=p.exports},d987:function(e,t,n){"use strict";var i=function(){var e=this,t=e.$createElement,n=e._self._c||t;return n("div",[e._t("editor"),e._t("default")],2)},s=[],r={name:"DynamicPage",props:{page:{type:Object,required:!0}}},a=r,l=n("2877"),o=Object(l["a"])(a,i,s,!1,null,null,null);t["a"]=o.exports},e57e:function(e,t,n){"use strict";n.r(t);var i=function(){var e=this,t=e.$createElement,n=e._self._c||t;return n("q-page",[e.page?n("dynamic-page",{attrs:{page:e.page}},e._l(e.page.sections,function(t,i){return n("dynamic-section",{key:"section_"+i,attrs:{section:t}},e._l(t.elements,function(e,i){return n("dynamic-element",{key:"element_"+i,attrs:{element:e,card:!t.fullwidth}})}),1)}),1):e._e(),n("q-inner-loading",{attrs:{showing:!e.page}},[n("q-spinner")],1),n("q-page-sticky",{attrs:{position:"top-left",offset:[16,16]}},[n("q-btn",{attrs:{icon:"mdi-view-list",color:"white","text-color":"black",size:"sm",round:""},on:{click:function(t){return e.$router.push("/website")}}})],1),n("q-page-sticky",{attrs:{position:"top-right",offset:[16,16]}},[n("q-btn",{attrs:{icon:"mdi-pencil",color:"white","text-color":"black",size:"sm",round:""},on:{click:function(t){return e.$router.push("/website/editor/"+e.path)}}})],1)],1)},s=[],r=n("967e"),a=n.n(r),l=(n("96cf"),n("fa84")),o=n.n(l),c=n("d987"),u=n("6a81"),m=n("8062"),d={name:"DynamicWebsite",components:{DynamicPage:c["a"],DynamicSection:u["a"],DynamicElement:m["a"]},props:{path:{type:String,required:!1,default:""}},watch:{$route:function(e,t){this.$store.dispatch("website/LOAD_PAGE",{path:e.params.path})}},computed:{page:function(){return this.$store.state.website.page}},methods:{},mounted:function(){var e=o()(a.a.mark(function e(){return a.a.wrap(function(e){while(1)switch(e.prev=e.next){case 0:return e.prev=0,e.next=3,this.$store.dispatch("website/LOAD_PAGE",{path:this.path});case 3:e.next=8;break;case 5:e.prev=5,e.t0=e["catch"](0),this.$gql.handleError(e.t0);case 8:case"end":return e.stop()}},e,this,[[0,5]])}));function t(){return e.apply(this,arguments)}return t}()},p=d,h=n("2877"),f=Object(h["a"])(p,i,s,!1,null,null,null);t["default"]=f.exports},ee6a:function(e,t,n){"use strict";var i=n("f1fc"),s=n.n(i);s.a},f1fc:function(e,t,n){var i=n("6620");"string"===typeof i&&(i=[[e.i,i,""]]),i.locals&&(e.exports=i.locals);var s=n("499e").default;s("293733f8",i,!1,{sourceMap:!1})}}]);