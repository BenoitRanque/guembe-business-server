(window["webpackJsonp"]=window["webpackJsonp"]||[]).push([["e721358a"],{4390:function(t,n,e){"use strict";var i=function(){var t=this,n=t.$createElement,e=t._self._c||n;return e("q-card",t._b({attrs:{flat:""}},"q-card",t.$attrs,!1),[t._t("header"),e("q-card-section",{staticClass:"text-subtitle2 row"},[t._v("\n    "+t._s(t.$i18n(t.listing,"name"))+"\n    "),e("q-space"),t._v("\n    Bs "+t._s((t.listing.total/100).toFixed(2))+"\n  ")],1),e("q-card-section",{staticClass:"text-caption"},[t._v("\n    "+t._s(t.$i18n(t.listing,"description"))+"\n  ")]),e("q-card-section",{staticClass:"q-px-none"},[e("q-expansion-item",{attrs:{dense:"",label:"Detalles","dense-toggle":"","default-opened":""},scopedSlots:t._u([{key:"header",fn:function(){return[e("q-item-section",[e("q-item-label",{attrs:{caption:""}},[t._v("\n            Mostrar Detalles\n          ")])],1)]},proxy:!0}])},[e("q-markup-table",{attrs:{separator:"none","wrap-cells":"",flat:"",dense:""}},[e("thead",[e("tr",[e("th",{staticClass:"text-left text-no-wrap"},[t._v("Producto Incluido")]),e("th",{staticClass:"text-right text-no-wrap"},[t._v("Precio Unitario")]),e("th",{staticClass:"text-right text-no-wrap"},[t._v("Cantidad")]),e("th",{staticClass:"text-right text-no-wrap"},[t._v("Subtotal")])])]),e("tbody",t._l(t.listing.listing_products,function(n,i){return e("tr",{key:i},[e("td",[e("div",{staticClass:"text-body2"},[t._v("\n                "+t._s(t.$i18n(n.product,"name"))+"\n              ")]),e("div",{staticClass:"text-caption"},[t._v("\n                "+t._s(t.$i18n(n.product,"description"))+"\n              ")])]),e("td",{staticClass:"text-right text-no-wrap"},[t._v("Bs "+t._s((n.price/100).toFixed(2)))]),e("td",{staticClass:"text-right text-no-wrap"},[t._v(t._s(n.quantity))]),e("td",{staticClass:"text-right text-no-wrap"},[t._v("Bs "+t._s((n.price/100*n.quantity).toFixed(2)))])])}),0)]),e("lifetime-display",{attrs:{lifetime:t.listing.lifetime}})],1)],1),t._t("footer")],2)},a=[],s=function(){var t=this,n=this,e=n.$createElement,i=n._self._c||e;return i("div",{staticClass:"text-caption cursor-pointer",nativeOn:{click:function(t){n.show=!n.show}}},[n._v("\n  "+n._s(n.$i18n(n.lifetime,"name"))+"\n  "),i("q-icon",{attrs:{name:"mdi-information"}},[i("q-tooltip",[n._v("\n      Haz click para mas detalles\n    ")])],1),i("q-menu",{model:{value:n.show,callback:function(t){n.show=t},expression:"show"}},[i("q-card",[i("q-card-section",[n._v("\n        "+n._s(n.$i18n(n.lifetime,"name"))+"\n      ")]),i("q-card-section",[n._v("\n        "+n._s(n.$i18n(n.lifetime,"description"))+"\n      ")]),i("q-card-section",[n._v("\n        "+n._s(n.lifetime.start)+"\n        -\n        "+n._s(n.lifetime.end)+"\n      ")]),i("q-card-section",[n._v("\n        "+n._s(n.lifetime.lifetime_weekdays.map(function(n){var e=n.weekday;return t.$i18n(e,"name")}).join(", "))+"\n      ")])],1)],1)],1)},r=[],o={name:"LifetimeDisplay",props:{lifetime:{required:!0,type:Object}},data:function(){return{show:!1}}},c=o,l=e("2877"),u=Object(l["a"])(c,s,r,!1,null,null,null),d=u.exports,p={name:"ListingDisplay",components:{LifetimeDisplay:d},props:{listing:{type:Object,required:!0}}},h=p,m=Object(l["a"])(h,i,a,!1,null,null,null);n["a"]=m.exports},c6c8:function(t,n,e){"use strict";var i=function(){var t=this,n=t.$createElement,e=t._self._c||n;return e("q-no-ssr",{staticClass:"my-custom-class"},[t.cart.length?t._e():e("q-banner",{staticClass:"bg-positive",attrs:{rounded:"","inline-actions":""},scopedSlots:t._u([{key:"action",fn:function(){return[e("q-btn",{attrs:{dense:"",flat:"",label:"Ir a tienda"},on:{click:function(n){return t.$router.push("/webstore/listings")}}})]},proxy:!0}],null,!1,3742586645)},[t._v("\n    Carrito vacio. Puede aggregar articulos en la tienda\n    ")]),t.someItemsNoLongerAvailable?e("q-banner",{staticClass:"bg-warning q-mb-md",attrs:{rounded:"","inline-actions":""},scopedSlots:t._u([{key:"action",fn:function(){return[e("q-btn",{attrs:{flat:"",label:"quitar articulos"},on:{click:t.removeUnavailableListings}})]},proxy:!0}],null,!1,1120638339)},[t._v("\n    Algunos articulos ya no se encuentran disponibles.\n    Debe quitarlos antes de proceder con la compra.\n    ")]):t._e(),t.someItemsHaveInsufficientStock?e("q-banner",{staticClass:"bg-warning q-mb-md",attrs:{rounded:"","inline-actions":""},scopedSlots:t._u([{key:"action",fn:function(){return[e("q-btn",{attrs:{flat:"",label:"Reducir cantidades"},on:{click:t.updateItemQuantities}})]},proxy:!0}],null,!1,953858677)},[t._v("\n    Algunos articulos no cuentan con stock sufficiente.\n    Debe reducir la cantidad antes de proceder.\n    ")]):t._e(),e("q-markup-table",{staticStyle:{"table-layout":"fixed"},attrs:{flat:"",dense:""}},[e("thead",[e("tr",[e("th",{staticClass:"text-left"},[t._v("Paquete")]),e("th",{staticClass:"text-right"},[t._v("Precio (unitario)")]),e("th",{staticClass:"text-right"},[t._v("Cantidad")]),e("th",{staticClass:"text-right"},[t._v("Subtotal")])])]),e("tbody",[t._l(t.cart,function(t,n){var i=t.listing,a=t.quantity;return e("cart-listing",{key:n,staticClass:"q-mb-md",attrs:{listing:i,quantity:a}})}),e("tr",{staticStyle:{background:"#fff"}},[e("td",{staticClass:"text-right text-subtitle2",attrs:{colspan:"4"}},[t._v("\n          Total: BS "+t._s((t.cart?t.cart.reduce(function(t,n){var e=n.quantity,i=n.listing.total;return t+i*e},0)/100:0).toFixed(2))+"\n        ")])])],2)]),e("q-inner-loading",{attrs:{showing:t.loading}},[e("q-spinner")],1)],1)},a=[],s=e("f3e3"),r=e.n(s),o=e("967e"),c=e.n(o),l=(e("96cf"),e("fa84")),u=e.n(l),d=e("02fa"),p=e.n(d),h=e("2f62"),m=function(){var t=this,n=t.$createElement,e=t._self._c||n;return e("tr",{staticClass:"cursor-pointer",on:{click:function(n){t.showDialog=!0}}},[e("td",[t._v("\n    "+t._s(t.$i18n(t.listing,"name"))+"\n  ")]),e("td",{staticClass:"text-right"},[t._v("\n    BS "+t._s((t.listing.total/100).toFixed(2))+"\n  ")]),e("td",{staticClass:"text-right"},[t._v("\n    "+t._s(t.quantity)+"\n  ")]),e("td",{staticClass:"text-right"},[t._v("\n    BS "+t._s((t.listing.total*t.quantity/100).toFixed(2))+"\n  ")]),e("q-dialog",{model:{value:t.showDialog,callback:function(n){t.showDialog=n},expression:"showDialog"}},[e("q-card",[e("q-bar",[t._v("\n        "+t._s(t.$i18n(t.listing,"name"))+"\n        "),e("q-space"),e("q-btn",{directives:[{name:"close-popup",rawName:"v-close-popup"}],attrs:{dense:"",flat:"",icon:"mdi-close"}})],1),e("listing-display",{attrs:{listing:t.listing},scopedSlots:t._u([{key:"footer",fn:function(){return[e("q-card-actions",[e("q-separator",{staticClass:"full-width q-mb-xs"}),e("div",{staticClass:"row full-width"},[e("q-btn",{staticClass:"col-auto",attrs:{color:"negative",flat:""},on:{click:t.removeFromCart}},[t._v("\n                Quitar\n                "),e("q-tooltip",[t._v("\n                  Quitar articulo del carrito\n                ")])],1),e("q-space"),e("q-form",{staticClass:"row",on:{submit:t.updateInCart,reset:function(n){t.amount=""}}},[e("q-input",{staticClass:"col-auto q-mr-xs",attrs:{type:"number",required:"",min:"1",label:"Cantidad en carrito: "+t.amountInCart,dense:"",square:"",outlined:""},model:{value:t.amount,callback:function(n){t.amount=n},expression:"amount"}}),e("q-btn",{staticClass:"col-auto",attrs:{type:"submit",color:"primary"}},[t._v("Guardar Cambios")])],1)],1)],1)]},proxy:!0}])})],1)],1)],1)},f=[],g=(e("c5f6"),e("4390")),v={name:"CartListing",components:{ListingDisplay:g["a"]},props:{quantity:{type:Number,required:!0},listing:{type:Object,required:!0}},data:function(){return{showDialog:!1,loading:!1,amount:""}},computed:{amountInCart:function(){return this.$store.getters["cart/listingInCart"](this.listing.listing_id).quantity}},methods:{removeFromCart:function(){var t=u()(c.a.mark(function t(){return c.a.wrap(function(t){while(1)switch(t.prev=t.next){case 0:return t.prev=0,this.loading=!0,t.next=4,this.$store.dispatch("cart/removeFromCart",{listingId:this.listing.listing_id});case 4:this.$q.notify({color:"positive",icon:"mdi-check",message:"Articulo quitado exitosamente"}),this.$emit("done"),this.showDialog=!1,t.next=12;break;case 9:t.prev=9,t.t0=t["catch"](0),this.$gql.handleError(t.t0);case 12:return t.prev=12,this.loading=!1,t.finish(12);case 15:case"end":return t.stop()}},t,this,[[0,9,12,15]])}));function n(){return t.apply(this,arguments)}return n}(),updateInCart:function(){var t=u()(c.a.mark(function t(){return c.a.wrap(function(t){while(1)switch(t.prev=t.next){case 0:return t.prev=0,this.loading=!0,t.next=4,this.$store.dispatch("cart/addToCart",{quantity:Number(this.amount),listing_id:this.listing.listing_id});case 4:this.$q.notify({color:"positive",icon:"mdi-check",message:"Cantidad modificada exitosamente"}),this.$emit("done"),this.showDialog=!1,t.next=12;break;case 9:t.prev=9,t.t0=t["catch"](0),this.$gql.handleError(t.t0);case 12:return t.prev=12,this.loading=!1,t.finish(12);case 15:case"end":return t.stop()}},t,this,[[0,9,12,15]])}));function n(){return t.apply(this,arguments)}return n}()},mounted:function(){}},_=v,b=e("2877"),q=Object(b["a"])(_,m,f,!1,null,null,null),y=q.exports,w={name:"ShoppingCart",components:{CartListing:y},data:function(){return{nit:0,razonSocial:"SIN NOMBRE",loading:!1}},computed:p()({},Object(h["d"])("cart",{cart:"listings"}),{someItemsNoLongerAvailable:function(){return!!this.cart&&this.cart.some(function(t){var n=t.listing;return n.inventory&&!n.inventory.available})},someItemsHaveInsufficientStock:function(){return!!this.cart&&this.cart.some(function(t){var n=t.quantity,e=t.listing;return e.inventory&&e.inventory.remaining<n})}}),methods:p()({},Object(h["b"])("cart",{loadCart:"loadCart"}),{checkout:function(){var t=u()(c.a.mark(function t(){var n,e,i;return c.a.wrap(function(t){while(1)switch(t.prev=t.next){case 0:return t.prev=0,this.loading=!0,t.next=4,this.createPurchase();case 4:return n=t.sent,e=n.purchase_id,t.next=8,this.createPayment(e);case 8:i=t.sent,window.location=i,t.next=15;break;case 12:t.prev=12,t.t0=t["catch"](0),this.$gql.handleError(t.t0);case 15:return t.prev=15,this.loading=!1,t.finish(15);case 18:case"end":return t.stop()}},t,this,[[0,12,15,18]])}));function n(){return t.apply(this,arguments)}return n}(),createPurchase:function(){var t=u()(c.a.mark(function t(){var n,e,i,a,s;return c.a.wrap(function(t){while(1)switch(t.prev=t.next){case 0:return n="\n        mutation createPurchase ($objects: [webstore_purchase_insert_input!]!) {\n          insert: insert_webstore_purchase (objects: $objects) {\n            returning {\n              purchase_id\n            }\n          }\n          remove: delete_store_cart_listing (where: {}) {\n            affected_rows\n          }\n        }\n      ",e={objects:{buyer_business_name:this.razonSocial,buyer_tax_identification_number:String(this.nit),purchase_listings:{data:this.cart.map(function(t){var n=t.listing_id,e=t.quantity;return{listing_id:n,quantity:e}})}}},t.next=4,this.$gql(n,e);case 4:return i=t.sent,a=r()(i.insert.returning,1),s=a[0],t.abrupt("return",s);case 8:case"end":return t.stop()}},t,this)}));function n(){return t.apply(this,arguments)}return n}(),createPayment:function(){var t=u()(c.a.mark(function t(n){var e,i;return c.a.wrap(function(t){while(1)switch(t.prev=t.next){case 0:return t.next=2,this.$api.post("/store/checkout/".concat(n),{payment:{return_url:"".concat(window.location.origin,"/webstore/purchase/").concat(n),cancel_url:"".concat(window.location.origin,"/webstore/cart"),payer_name:"Benoit Ranque",payer_email:"ranque.benoit@gmail.com"}});case 2:return e=t.sent,i=e.data.khipu_payment_url,t.abrupt("return",i);case 5:case"end":return t.stop()}},t,this)}));function n(n){return t.apply(this,arguments)}return n}(),updateCart:function(){var t=u()(c.a.mark(function t(){return c.a.wrap(function(t){while(1)switch(t.prev=t.next){case 0:return t.prev=0,this.loading=!0,t.next=4,this.loadCart();case 4:t.next=9;break;case 6:t.prev=6,t.t0=t["catch"](0),this.$gql.handleError(t.t0);case 9:return t.prev=9,this.loading=!1,t.finish(9);case 12:case"end":return t.stop()}},t,this,[[0,6,9,12]])}));function n(){return t.apply(this,arguments)}return n}(),removeUnavailableListings:function(){var t=u()(c.a.mark(function t(){var n,e,i;return c.a.wrap(function(t){while(1)switch(t.prev=t.next){case 0:return n="\n        mutation {\n          listings: delete_webstore_cart_listing (where: {\n            listing: {\n              _not: {\n                inventory: {\n                  available: {\n                    _eq: true\n                  }\n                }\n              }\n            }\n          }) {\n            removed: affected_rows\n          }\n        }\n      ",t.prev=1,this.loading=!0,t.next=5,this.$gql(n);case 5:e=t.sent,i=e.listings.removed,this.$q.notify({color:"positive",icon:"mdi-check",message:"Se removieron ".concat(i," items")}),t.next=13;break;case 10:t.prev=10,t.t0=t["catch"](1),this.$gql.handleError(t.t0);case 13:return t.prev=13,this.loading=!0,t.finish(13);case 16:this.updateCart();case 17:case"end":return t.stop()}},t,this,[[1,10,13,16]])}));function n(){return t.apply(this,arguments)}return n}(),updateItemQuantities:function(){var t=u()(c.a.mark(function t(){var n,e,i,a;return c.a.wrap(function(t){while(1)switch(t.prev=t.next){case 0:return n="\n        mutation updateListingQuantity ($objects: [store_cart_listing_insert_input!]!) {\n          listings: insert_store_cart_listing (objects: $objects on_conflict: {\n            constraint: cart_listing_pkey\n            update_columns: [quantity]\n          }) {\n            updated: affected_rows\n          }\n        }\n      ",e={objects:this.cart.filter(function(t){var n=t.listing,e=t.quantity;return n.inventory&&n.inventory.remaining<e}).map(function(t){var n=t.listing_id,e=t.listing.inventory.remaining;return{quantity:e,listing_id:n}})},t.prev=2,this.loading=!0,t.next=6,this.$gql(n,e);case 6:i=t.sent,a=i.listings.updated,this.$q.notify({color:"positive",icon:"mdi-check",message:"Se actualizaron ".concat(a," items")}),t.next=14;break;case 11:t.prev=11,t.t0=t["catch"](2),this.$gql.handleError(t.t0);case 14:return t.prev=14,this.loading=!0,t.finish(14);case 17:this.updateCart();case 18:case"end":return t.stop()}},t,this,[[2,11,14,17]])}));function n(){return t.apply(this,arguments)}return n}()}),mounted:function(){this.updateCart()}},x=w,C=Object(b["a"])(x,i,a,!1,null,null,null);n["a"]=C.exports}}]);