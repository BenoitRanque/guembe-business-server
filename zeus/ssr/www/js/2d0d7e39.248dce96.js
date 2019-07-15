(window["webpackJsonp"]=window["webpackJsonp"]||[]).push([["2d0d7e39"],{7978:function(e,t,n){"use strict";n.r(t);var s=function(){var e=this,t=e.$createElement,n=e._self._c||t;return n("q-page",{attrs:{padding:""}},[n("q-table",{attrs:{title:"Productos vigentes: "+e.client.name,"selected-rows-label":function(e){return e+" producto"+(1===e?"":"s")+" seleccionado"+(1===e?"":"s")},data:e.table.data,columns:e.table.columns,"row-key":"purchased_product_id",selection:"multiple",selected:e.table.selected,pagination:e.table.pagination,filter:e.table.filter,loading:e.table.loading,"rows-per-page-options":e.table.rowsPerPageOptions,grid:""},on:{"update:selected":function(t){return e.$set(e.table,"selected",t)},"update:pagination":function(t){return e.$set(e.table,"pagination",t)},request:e.loadProducts},scopedSlots:e._u([{key:"top-right",fn:function(){return[n("q-btn",{staticClass:"q-mx-sm",attrs:{color:"accent",disable:!e.table.selected.length},on:{click:e.useProducts}},[e._v("Canjear productos")]),n("q-input",{attrs:{borderless:"",dense:"",debounce:"300",placeholder:"Buscar"},scopedSlots:e._u([{key:"append",fn:function(){return[n("q-icon",{attrs:{name:"mdi-magnify"}})]},proxy:!0}]),model:{value:e.table.filter,callback:function(t){e.$set(e.table,"filter",t)},expression:"table.filter"}})]},proxy:!0},{key:"item",fn:function(t){return[n("div",{staticClass:"q-pa-xs col-xs-12 col-sm-6 col-md-4 col-lg-3 grid-style-transition",style:t.selected?"transform: scale(0.95);":""},[n("q-card",{class:t.selected?"bg-green-4":"bg-green-2",on:{click:function(e){t.selected=!t.selected}}},[n("q-card-section",[n("q-checkbox",{attrs:{dense:""},model:{value:t.selected,callback:function(n){e.$set(t,"selected",n)},expression:"props.selected"}},[n("div",{staticClass:"text-h6"},[e._v(e._s(t.row.product.public_name))])])],1),n("q-separator"),n("q-card-section",{staticClass:"text-body2"},[e._v("\n            "+e._s(t.row.product.private_name)+"\n          ")]),n("q-card-section",{staticClass:"text-caption"},[e._v("\n            "+e._s(t.row.product.description)+"\n          ")]),n("q-card-section",{staticClass:"text-caption"},[n("lifetime",{attrs:{lifetime:t.row.lifetime}})],1)],1)],1)]}}])}),n("q-inner-loading",{attrs:{showing:e.loading}},[n("q-spinner")],1)],1)},a=[],i=n("02fa"),r=n.n(i),o=n("967e"),c=n.n(o),l=(n("96cf"),n("fa84")),d=n.n(l),u=function(){var e=this,t=e.$createElement,n=e._self._c||t;return n("div",{staticClass:"text-bold"},[n("div",{staticClass:"text-primary row justify-between"},[n("span",{staticClass:"q-px-xs"},[e._v("\n      "+e._s(e.lifetime.start.replace(/-/g,"/"))+"\n      "),n("q-tooltip",[e._v("\n        Producto vigente desde fecha "+e._s(e.lifetime.start.replace(/-/g,"/"))+"\n      ")])],1),n("span",{staticClass:"q-px-xs text-body2 text-bold text-black"},[e._v("\n      Vigencia\n      "),n("q-tooltip",[e._v("\n        Vigencia del producto\n      ")])],1),n("span",{staticClass:"q-px-xs"},[e._v("\n      "+e._s(e.lifetime.end.replace(/-/g,"/"))+"\n      "),n("q-tooltip",[e._v("\n        Producto vigente hasta fecha "+e._s(e.lifetime.end.replace(/-/g,"/"))+"\n      ")])],1)]),n("div",{staticClass:"text-grey row justify-between text-center"},[n("span",{staticClass:"q-px-xs",class:{"text-primary":e.includeWeekday(1)}},[e._v("\n      Lun\n      "),n("q-tooltip",[e._v("\n        Producto "+e._s(e.includeWeekday(1)?"":"no")+" vigente los dias Lunes\n      ")])],1),n("span",{staticClass:"q-px-xs",class:{"text-primary":e.includeWeekday(2)}},[e._v("\n      Mar\n      "),n("q-tooltip",[e._v("\n        Producto "+e._s(e.includeWeekday(2)?"":"no")+" vigente los dias Martes\n      ")])],1),n("span",{staticClass:"q-px-xs",class:{"text-primary":e.includeWeekday(3)}},[e._v("\n      Mie\n      "),n("q-tooltip",[e._v("\n        Producto "+e._s(e.includeWeekday(3)?"":"no")+" vigente los dias Miercoles\n      ")])],1),n("span",{staticClass:"q-px-xs",class:{"text-primary":e.includeWeekday(4)}},[e._v("\n      Jue\n      "),n("q-tooltip",[e._v("\n        Producto "+e._s(e.includeWeekday(4)?"":"no")+" vigente los dias Jueves\n      ")])],1),n("span",{staticClass:"q-px-xs",class:{"text-primary":e.includeWeekday(5)}},[e._v("\n      Vie\n      "),n("q-tooltip",[e._v("\n        Producto "+e._s(e.includeWeekday(5)?"":"no")+" vigente los dias Viernes\n      ")])],1),n("span",{staticClass:"q-px-xs",class:{"text-primary":e.includeWeekday(6)}},[e._v("\n      Sab\n      "),n("q-tooltip",[e._v("\n        Producto "+e._s(e.includeWeekday(6)?"":"no")+" vigente los dias Sabado\n      ")])],1),n("span",{staticClass:"q-px-xs",class:{"text-primary":e.includeWeekday(0)}},[e._v("\n      Dom\n      "),n("q-tooltip",[e._v("\n        Producto "+e._s(e.includeWeekday(0)?"":"no")+" vigente los dias Domingo\n      ")])],1),n("span",{staticClass:"q-px-xs",class:{"text-primary":e.lifetime.include_holidays}},[e._v("\n      Feriados\n      "),n("q-tooltip",[e._v("\n        Producto "+e._s(e.lifetime.include_holidays?"":"no")+" vigente los dias Feriados\n      ")])],1)])])},p=[],_={name:"Lifetime",props:{lifetime:{type:Object,required:!0}},methods:{includeWeekday:function(e){return this.lifetime.lifetime_weekdays.some(function(t){var n=t.weekday_id;return n===e})}}},m=_,g=n("2877"),f=Object(g["a"])(m,u,p,!1,null,null,null),h=f.exports,v={name:"ClientProductUsable",components:{Lifetime:h},props:{clientId:{type:String,required:!0}},data:function(){return{loading:!1,client:{},table:{loading:!1,data:[],columns:[],rowsPerPageOptions:[3,4,6,8,9,12,15,16,18,20,24],selected:[],pagination:{sortBy:null,descending:!1,page:1,rowsPerPage:6,rowsNumber:0},filter:""}}},methods:{useProducts:function(){var e=this;this.table.selected.length?this.$q.dialog({title:"Canjear Productos",message:"Desea registrar el canje de ".concat(this.table.selected.length," productos?"),ok:{color:"primary"},cancel:!0}).onOk(d()(c.a.mark(function t(){var n,s,a,i;return c.a.wrap(function(t){while(1)switch(t.prev=t.next){case 0:return n="mutation ($objects: [store_purchased_product_use_insert_input!]!) {\n          insert: insert_store_purchased_product_use (objects: $objects) {\n            count: affected_rows\n          }\n        }",s={objects:e.table.selected.map(function(e){var t=e.purchased_product_id;return{purchased_product_id:t}})},t.prev=2,e.loading=!0,t.next=6,e.$gql(n,s,{role:"administrator"});case 6:a=t.sent,i=a.insert.count,e.$q.notify({icon:"mdi-check",color:"positive",message:"".concat(i," producto").concat(i>1?"s":""," canjeado").concat(i>1?"s":"")}),e.table.selected=[],t.next=15;break;case 12:t.prev=12,t.t0=t["catch"](2),e.$gql.handleError(t.t0);case 15:return t.prev=15,e.loading=!1,e.loadProducts(),t.finish(15);case 19:case"end":return t.stop()}},t,null,[[2,12,15,19]])}))):this.$q.notify({icon:"mdi-alert",color:"warning",message:"Debe selecionar por lo menos 1 producto para canjear"})},loadProducts:function(){var e=d()(c.a.mark(function e(){var t,n,s,a,i,o,l,d,u,p=arguments;return c.a.wrap(function(e){while(1)switch(e.prev=e.next){case 0:return t=p.length>0&&void 0!==p[0]?p[0]:{},n=t.pagination,s=t.filter,a=void 0===s?"":s,n||(n=this.table.pagination),i="query ($where: store_purchased_product_bool_exp! $offset: Int! $limit: Int! $order_by: [store_purchased_product_order_by!]) {\n        meta: store_purchased_product_aggregate (where: $where) {\n          rows: aggregate {\n            count\n          }\n        }\n        data: store_purchased_product (where: $where offset: $offset limit: $limit order_by: $order_by) {\n          purchased_product_id\n          product {\n            private_name\n            public_name\n            description\n          }\n          lifetime {\n            include_holidays\n            start\n            end\n            lifetime_weekdays {\n              weekday_id\n            }\n          }\n        }\n      }",o={limit:n.rowsPerPage,offset:n.rowsPerPage*(n.page-1),order_by:[{lifetime:{end:"asc"}},{product:{public_name:"asc"}}],where:{purchased_product_usable:{},client_id:{_eq:this.clientId},product:a?{_or:[{private_name:{_ilike:"%".concat(a,"%")}},{public_name:{_ilike:"%".concat(a,"%")}},{description:{_ilike:"%".concat(a,"%")}}]}:null}},e.prev=4,this.table.loading=!0,e.next=8,this.$gql(i,o,{role:"administrator"});case 8:l=e.sent,d=l.data,u=l.meta.rows.count,this.table.pagination=r()({},n,{rowsNumber:u}),this.table.data=d,e.next=18;break;case 15:e.prev=15,e.t0=e["catch"](4),this.$gql.handleError(e.t0);case 18:return e.prev=18,this.table.loading=!1,e.finish(18);case 21:case"end":return e.stop()}},e,this,[[4,15,18,21]])}));function t(){return e.apply(this,arguments)}return t}(),loadClient:function(){var e=d()(c.a.mark(function e(){var t,n,s,a;return c.a.wrap(function(e){while(1)switch(e.prev=e.next){case 0:return t="query ($client_id: uuid!) {\n        client: store_client_by_pk (client_id: $client_id) {\n          client_id\n          name\n        }\n      }",n={client_id:this.clientId},e.prev=2,this.loading=!0,e.next=6,this.$gql(t,n,{role:"administrator"});case 6:s=e.sent,a=s.client,this.client=a,e.next=14;break;case 11:e.prev=11,e.t0=e["catch"](2),this.$gql.handleError(e.t0);case 14:return e.prev=14,this.loading=!1,e.finish(14);case 17:case"end":return e.stop()}},e,this,[[2,11,14,17]])}));function t(){return e.apply(this,arguments)}return t}()},mounted:function(){this.loadProducts(),this.loadClient()}},b=v,x=Object(g["a"])(b,s,a,!1,null,null,null);t["default"]=x.exports}}]);