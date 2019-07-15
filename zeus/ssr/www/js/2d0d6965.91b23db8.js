(window["webpackJsonp"]=window["webpackJsonp"]||[]).push([["2d0d6965"],{"72d8":function(e,t,n){"use strict";n.r(t);var a=function(){var e=this,t=e.$createElement,n=e._self._c||t;return n("q-page",{attrs:{padding:""}},[n("q-table",{attrs:{flat:"",title:"Clientes",data:e.table.data,columns:e.table.columns,"row-key":"client_id",pagination:e.table.pagination,filter:e.table.filter,loading:e.table.loading},on:{"update:pagination":function(t){return e.$set(e.table,"pagination",t)},request:e.loadClients},scopedSlots:e._u([{key:"top-right",fn:function(){return[n("q-btn",{staticClass:"q-mx-sm",attrs:{color:"accent"},on:{click:function(t){e.showClientIdentificationDialog=!0}}},[e._v("Identificar cliente")]),n("q-input",{attrs:{borderless:"",dense:"",debounce:"300",placeholder:"Buscar"},scopedSlots:e._u([{key:"append",fn:function(){return[n("q-icon",{attrs:{name:"mdi-magnify"}})]},proxy:!0}]),model:{value:e.table.filter,callback:function(t){e.$set(e.table,"filter",t)},expression:"table.filter"}})]},proxy:!0},{key:"body-cell-purchases",fn:function(t){return[n("q-td",{attrs:{props:t,"auto-width":""}},[n("q-btn",{attrs:{"no-wrap":"",flat:"",size:"sm",label:"Compras","icon-right":"mdi-open-in-new"},on:{click:function(n){return e.$router.push("/client/"+t.row.client_id+"/purchases")}}}),n("q-tooltip",[e._v("\n          Ver compras\n        ")])],1)]}},{key:"body-cell-purchased_products",fn:function(t){return[n("q-td",{attrs:{props:t,"auto-width":""}},[n("q-btn",{attrs:{"no-wrap":"",flat:"",size:"sm",label:"Productos Comprados","icon-right":"mdi-open-in-new"},on:{click:function(n){return e.$router.push("/client/"+t.row.client_id+"/purchasedproducts")}}}),n("q-tooltip",[e._v("\n          Ver productos comprados\n        ")])],1)]}},{key:"body-cell-purchased_products_use",fn:function(t){return[n("q-td",{attrs:{props:t,"auto-width":""}},[n("q-btn",{attrs:{"no-wrap":"",flat:"",size:"sm",label:"Uso de Productos","icon-right":"mdi-open-in-new"},on:{click:function(n){return e.$router.push("/client/"+t.row.client_id+"/purchasedproducts/use")}}}),n("q-tooltip",[e._v("\n          Ver uso de productos\n        ")])],1)]}},{key:"body-cell-details",fn:function(t){return[n("q-td",{attrs:{props:t,"auto-width":""}},[n("q-btn",{attrs:{"no-wrap":"",flat:"",size:"sm",label:"Detalles","icon-right":"mdi-open-in-new"},on:{click:function(n){return e.$router.push("/client/"+t.row.client_id)}}}),n("q-tooltip",[e._v("\n          Ver detalles de cliente\n        ")])],1)]}}])}),n("q-dialog",{attrs:{persistent:""},model:{value:e.showClientIdentificationDialog,callback:function(t){e.showClientIdentificationDialog=t},expression:"showClientIdentificationDialog"}},[n("client-identification")],1)],1)},i=[],r=n("967e"),o=n.n(r),s=n("02fa"),l=n.n(s),c=(n("96cf"),n("fa84")),d=n.n(c),u=(n("7f7f"),n("bd4c")),p=function(){var e=this,t=e.$createElement,n=e._self._c||t;return n("q-card",{staticStyle:{width:"260px"}},[n("q-bar",[e._v("\n    Identificar Cliente\n    "),n("q-space"),n("q-btn",{directives:[{name:"close-popup",rawName:"v-close-popup"}],attrs:{flat:"",dense:"",icon:"mdi-close"}})],1),n("q-form",{attrs:{autofocus:""},on:{submit:e.submit,reset:e.reset}},[n("q-card-section",[n("q-input",{attrs:{label:"Codigo O Token Cliente",filled:"",required:""},model:{value:e.token,callback:function(t){e.token=t},expression:"token"}})],1),n("q-separator"),n("q-card-actions",{attrs:{align:"around"}},[n("q-btn",{attrs:{color:"primary",type:"submit"}},[e._v("Identificar")])],1)],1),n("q-inner-loading",{attrs:{showing:e.loading}},[n("q-spinner")],1)],1)},f=[],h=n("f3e3"),m=n.n(h),b=(n("c5f6"),/^[0-9]+$/),g=/^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/,w={name:"ClientIdentification",data:function(){return{loading:!1,token:""}},methods:{submit:function(){var e=d()(o.a.mark(function e(){var t,n,a,i,r;return o.a.wrap(function(e){while(1)switch(e.prev=e.next){case 0:if(t="query ($where: store_client_token_bool_exp!) {\n        tokens: store_client_token (where: $where) {\n          client_id\n        }\n      }",n={},!g.test(this.token)){e.next=6;break}n.where={token_id:{_eq:this.token}},e.next=13;break;case 6:if(!b.test(this.token)){e.next=10;break}n.where={code:{_eq:Number(this.token)}},e.next=13;break;case 10:return this.$q.notify({color:"warning",icon:"mdi-alert",message:"Formato de token invalido: ".concat(this.token)}),this.reset(),e.abrupt("return");case 13:return e.prev=13,this.loading=!0,e.next=17,this.$gql(t,n,{role:"administrator"});case 17:a=e.sent,i=m()(a.tokens,1),r=i[0],r?this.$router.push("/client/".concat(r.client_id)):this.$q.notify({icon:"mdi-alert",color:"warning",message:"Token invalido o epxirado. Intente de nuevo"}),e.next=26;break;case 23:e.prev=23,e.t0=e["catch"](13),this.$gql.handleError(e.t0);case 26:return e.prev=26,this.loading=!1,e.finish(26);case 29:case"end":return e.stop()}},e,this,[[13,23,26,29]])}));function t(){return e.apply(this,arguments)}return t}(),reset:function(){this.token=""}}},_=w,k=n("2877"),q=Object(k["a"])(_,p,f,!1,null,null,null),v=q.exports,y=u["b"].formatDate,$={name:"Clients",components:{ClientIdentification:v},data:function(){return{showClientIdentificationDialog:!1,loading:!1,clients:[],table:{loading:!1,data:[],columns:[{name:"name",label:"Nombre",align:"left",field:function(e){return e.name},format:function(e,t){return e}},{name:"created_at",label:"Fecha Hora",align:"left",field:"created_at",format:function(e,t){return y(e,"YYYY/MM/DD HH:mm")}},{name:"purchases",label:"Compras",align:"center"},{name:"purchased_products",label:"Productos Comprados",align:"center"},{name:"purchased_products_use",label:"Uso de Productos",align:"center"},{name:"details",label:"Detalles"}],pagination:{sortBy:null,descending:!1,page:1,rowsPerPage:10,rowsNumber:0},filter:""}}},methods:{loadClients:function(){var e=d()(o.a.mark(function e(){var t,n,a,i,r,s,c,d,u,p=arguments;return o.a.wrap(function(e){while(1)switch(e.prev=e.next){case 0:return t=p.length>0&&void 0!==p[0]?p[0]:{},n=t.pagination,a=t.filter,i=void 0===a?"":a,n||(n=this.table.pagination),r="query ($where: store_client_bool_exp! $offset: Int! $limit: Int! $order_by: [store_client_order_by!]) {\n        meta: store_client_aggregate (where: $where) {\n          rows: aggregate {\n            count\n          }\n        }\n        data: store_client (where: $where offset: $offset limit: $limit order_by: $order_by) {\n          client_id\n          created_at\n          name\n        }\n      }",s={limit:n.rowsPerPage,offset:n.rowsPerPage*(n.page-1),order_by:[{created_at:"desc"}],where:{_or:i?[{name:{_ilike:"%".concat(i,"%")}}]:[{}]}},e.prev=4,this.table.loading=!0,e.next=8,this.$gql(r,s,{role:"administrator"});case 8:c=e.sent,d=c.data,u=c.meta.rows.count,this.table.pagination=l()({},n,{rowsNumber:u}),this.table.data=d,e.next=18;break;case 15:e.prev=15,e.t0=e["catch"](4),this.$gql.handleError(e.t0);case 18:return e.prev=18,this.table.loading=!1,e.finish(18);case 21:case"end":return e.stop()}},e,this,[[4,15,18,21]])}));function t(){return e.apply(this,arguments)}return t}()},mounted:function(){this.loadClients()}},x=$,C=Object(k["a"])(x,a,i,!1,null,null,null);t["default"]=C.exports}}]);