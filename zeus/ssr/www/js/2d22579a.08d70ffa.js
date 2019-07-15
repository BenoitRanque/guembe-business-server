(window["webpackJsonp"]=window["webpackJsonp"]||[]).push([["2d22579a"],{e50d:function(t,e,i){"use strict";i.r(e);var n=function(){var t=this,e=t.$createElement,i=t._self._c||e;return i("q-page",{attrs:{padding:""}},[t.listing?i("div",{staticClass:"row q-col-gutter-md"},[i("div",{staticClass:"col-8"},[i("div",{staticClass:"text-h6"},[t._v("\n        "+t._s(t.listing.name)+"\n      ")]),i("div",{staticClass:"text-subtitle2"},[t._v("\n        Disponible Desde: "+t._s(t.listing.available_from)+"\n      ")]),i("div",{staticClass:"text-subtitle2"},[t._v("\n        Disponible Hasta: "+t._s(t.listing.available_to)+"\n      ")]),t.listing.inventory?[i("pre",[t._v(t._s(t.listing.inventory))])]:t._e(),i("q-markup-table",{staticClass:"relative-position",attrs:{flat:""}},[i("thead",[i("tr",[i("th",{staticClass:"text-left",staticStyle:{width:"30%"}},[t._v("Producto")]),i("th",{staticClass:"text-left",staticStyle:{width:"20%"}},[t._v("Precio (unitario)")]),i("th",{staticClass:"text-left",staticStyle:{width:"20%"}},[t._v("Cantidad")]),i("th",{staticClass:"text-left",staticStyle:{width:"30%"}},[t._v("Tiempo de vida")])])]),i("tbody",t._l(t.listing.listing_products,function(e,n){return i("tr",{key:n},[i("td",[t._v("\n              "+t._s(e.product.name)+"\n            ")]),i("td",[t._v("\n              "+t._s((e.price/100).toFixed(2))+"\n            ")]),i("td",[t._v("\n              "+t._s(e.quantity)+"\n            ")]),i("td",[t._v("\n              "+t._s(e.lifetime.name)+"\n            ")])])}),0)])],2),i("q-list",{staticClass:"col-4"},[t._l(t.listing.listing_images,function(e,n){return i("q-item",{key:n},[i("q-item-section",[i("q-img",{staticClass:"rounded-borders",attrs:{src:"https://chuturubi.com/api/v1/image/listing/"+e.image_id}},[i("span",{staticClass:"absolute-bottom q-py-sm q-px-md text-white row items-center absolute-position",staticStyle:{background:"rgba(0, 0, 0, 0.47)"}},[i("div",{staticClass:"col text-caption"},[t._v("\n                "+t._s(e.name)+"\n              ")]),i("div",{staticClass:"col-auto q-mr-xs"},[i("q-btn",{attrs:{dense:"",icon:"mdi-star",flat:"",size:"sm",color:e.highlighted?"yellow":"grey"},on:{click:function(i){return t.highlightImage(e)}}},[i("q-tooltip",[t._v("\n                    "+t._s(e.highlighted?"Esta imagen es resaltada":"Marcar como imagen resaltada")+"\n                  ")])],1)],1),i("div",{staticClass:"col-auto"},[i("q-btn",{attrs:{dense:"",icon:"mdi-delete-outline",size:"sm",color:"negative"},on:{click:function(i){return t.confirmRemoveImage(e.image_id)}}},[i("q-tooltip",[t._v("\n                    Eliminar esta imagen\n                  ")])],1)],1)])])],1)],1)}),i("q-item",[i("q-item-section",[i("q-uploader",{ref:"uploader",staticClass:"full-width",attrs:{multiple:"","auto-upload":"","with-credentials":"",label:"Aggregar Imagenes",bordered:"",flat:"",url:"https://chuturubi.com/api/v1/image/listing/upload/"+t.listingId,accept:".jpg, .png, image/*","field-name":"image",headers:function(){return[{name:"Authorization",value:"session-auth "+t.$q.sessionStorage.getItem("session-auth")}]}},on:{finish:t.loadData}})],1)],1)],2)],1):t._e(),i("q-inner-loading",{attrs:{showing:t.loading}},[i("q-spinner")],1)],1)},a=[],s=i("967e"),r=i.n(s),l=(i("96cf"),i("fa84")),o=i.n(l),c={name:"Listing",props:{listingId:{required:!0,type:String}},data:function(){return{loading:!1,listing:null}},methods:{highlightImage:function(){var t=o()(r.a.mark(function t(e){var i,n,a,s;return r.a.wrap(function(t){while(1)switch(t.prev=t.next){case 0:return i=e.highlighted,n=e.image_id,a="mutation ($where: store_listing_image_bool_exp! $set: store_listing_image_set_input) {\n        update_store_listing_image (where: $where _set: $set) {\n          affected_rows\n        }\n      }",s={where:{image_id:{_eq:n}},set:{highlighted:!i}},t.prev=3,t.next=6,this.$gql(a,s,{role:"administrator"});case 6:this.loadData(),t.next=12;break;case 9:t.prev=9,t.t0=t["catch"](3),this.$gql.handleError(t.t0);case 12:case"end":return t.stop()}},t,this,[[3,9]])}));function e(e){return t.apply(this,arguments)}return e}(),confirmRemoveImage:function(t){var e=this;this.$q.dialog({title:"Eliminar imagen?",message:"Esta imagen sera eliminada de manera permanente",persistent:!0,cancel:!0}).onOk(function(){return e.removeImage(t)})},removeImage:function(){var t=o()(r.a.mark(function t(e){var i,n,a,s;return r.a.wrap(function(t){while(1)switch(t.prev=t.next){case 0:return i="mutation ($where: store_listing_image_bool_exp!) {\n        image: delete_store_listing_image (where: $where) {\n          removed: affected_rows\n        }\n      }",n={where:{image_id:{_eq:e}}},t.prev=2,this.loading=!0,t.next=6,this.$gql(i,n,{role:"administrator"});case 6:a=t.sent,s=a.image.removed,this.$q.notify({icon:"mdi-check",color:"positive",message:"".concat(s," Imagen eliminada")}),t.next=14;break;case 11:t.prev=11,t.t0=t["catch"](2),this.$gql.handleError(t.t0);case 14:return t.prev=14,this.loading=!1,this.loadData(),t.finish(14);case 18:case"end":return t.stop()}},t,this,[[2,11,14,18]])}));function e(e){return t.apply(this,arguments)}return e}(),loadData:function(){var t=o()(r.a.mark(function t(){var e,i,n,a;return r.a.wrap(function(t){while(1)switch(t.prev=t.next){case 0:return e="query ($listing_id: uuid!) {\n        data: webstore_listing_by_pk (listing_id: $listing_id) {\n          listing_id\n          name\n          available_from\n          available_to\n          supply\n          inventory {\n            supply\n            used\n            remaining\n            available\n          }\n          listing_products {\n            product {\n              name\n            }\n            price\n            quantity\n            lifetime {\n              name\n            }\n          }\n        }\n      }",i={listing_id:this.listingId},t.prev=2,this.loading=!0,t.next=6,this.$gql(e,i,{role:"administrator"});case 6:n=t.sent,a=n.data,this.listing=a,t.next=14;break;case 11:t.prev=11,t.t0=t["catch"](2),this.$gql.handleError(t.t0);case 14:return t.prev=14,this.loading=!1,t.finish(14);case 17:case"end":return t.stop()}},t,this,[[2,11,14,17]])}));function e(){return t.apply(this,arguments)}return e}()},mounted:function(){this.loadData()}},d=c,g=i("2877"),u=Object(g["a"])(d,n,a,!1,null,null,null);e["default"]=u.exports}}]);