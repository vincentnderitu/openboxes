<%@ page import="org.pih.warehouse.core.Constants;" %>
<%@ page import="org.pih.warehouse.order.OrderType;" %>
<%@ page import="org.pih.warehouse.order.OrderTypeCode;" %>


<script>
  $(document).ready(function() {
    $("#orderItemsStatusFilter").keyup(function(event){
      const filterCells = [1, 2]; // filter by product code or name
      const filterValue = $("#orderItemsStatusFilter")
        .val()
        .toUpperCase();
      const tableRows = $("#order-items-status tr.dataRowItemStatus");
      filterTableItems(filterCells, filterValue, tableRows)
    });

  });
</script>


<div id="tab-content" class="box">
    <h2>
        <warehouse:message code="order.itemStatus.label" default="Item Status"/>
    </h2>
    <g:if test="${orderInstance.orderType != OrderType.findByCode(Constants.PUTAWAY_ORDER)}">
        <input type="text" id="orderItemsStatusFilter" class="text large" placeholder="${g.message(code: 'order.filterByProduct.label', default: 'Filter by product name or code')}"/>
    </g:if>
    <g:if test="${orderInstance?.orderItems }">
        <table class="table table-bordered" id="order-items-status">
            <thead>
            <tr class="odd">
                <th class="bottom">
                    <warehouse:message code="default.status.label"/>
                </th>
                <th><warehouse:message code="product.productCode.label" /></th>
                <th><warehouse:message code="product.label" /></th>
                <th class="center">${warehouse.message(code: 'product.unitOfMeasure.label')}</th>
                <th class="right">${warehouse.message(code: 'orderItem.quantity.label')}</th>
                <g:if test="${orderInstance.orderType==OrderType.findByCode(OrderTypeCode.PURCHASE_ORDER.name())}">
                    <th class="right">${warehouse.message(code: 'order.shipped.label')}</th>
                    <th class="right">${warehouse.message(code: 'order.received.label')}</th>
                    <th class="right">${warehouse.message(code: 'invoice.invoiced.label')}</th>
                    <th><warehouse:message code="order.unitPrice.label" /></th>
                    <th><warehouse:message code="order.totalPrice.label" /></th>
                </g:if>
                <g:elseif test="${orderInstance.orderType==OrderType.findByCode(Constants.PUTAWAY_ORDER)}">
                    <th><warehouse:message code="inventoryItem.lotNumber.label" /></th>
                    <th><warehouse:message code="inventoryItem.expirationDate.label" /></th>
                    <th><warehouse:message code="orderItem.originBinLocation.label" /></th>
                    <th><warehouse:message code="orderItem.destinationBinLocation.label" /></th>
                </g:elseif>
                %{-- When adding/removing a column, make sure to check the filterCell in function for filtering above --}%
            </tr>
            </thead>
            <tbody>
            <g:set var="orderItemsDerivedStatus" value="${orderInstance?.getOrderItemsDerivedStatus()}"/>
            <g:each var="orderItem" in="${orderInstance?.listOrderItems()}" status="i">
                <tr class="order-item ${(i % 2) == 0 ? 'even' : 'odd'} dataRowItemStatus">
                    <g:if test="${orderInstance?.isPurchaseOrder}">
                        <td>
                            <div class="tag ${orderItem?.canceled ? 'tag-danger' : ''}">
                                <format:metadata obj="${!orderItem?.canceled && orderItemsDerivedStatus[orderItem?.id] ? orderItemsDerivedStatus[orderItem?.id] : orderItem?.orderItemStatusCode?.name()}"/>
                            </div>
                        </td>
                    </g:if>
                    <g:if test="${orderInstance.orderType==OrderType.findByCode(Constants.PUTAWAY_ORDER)}">
                        <td>
                            ${orderItem?.orderItemStatusCode}
                        </td>
                    </g:if>
                    <td>
                        ${orderItem?.product?.productCode?:""}
                    </td>

                <td class="order-item-product">
                    <g:if test="${orderItem?.product }">
                        <g:link controller="inventoryItem" action="showStockCard" params="['product.id':orderItem?.product?.id]">
                            <format:product product="${orderItem?.product}"/>
                            <g:renderHandlingIcons product="${orderItem?.product}" />
                        </g:link>
                    </g:if>
                    <g:else>
                        ${orderItem?.description }
                    </g:else>
                </td>
                <td class="center">
                    ${orderItem?.unitOfMeasure}
                </td>
                <td class="order-item-quantity right">
                    ${orderItem?.quantity}
                </td>
                <g:if test="${orderInstance.orderType==OrderType.findByCode(OrderTypeCode.PURCHASE_ORDER.name())}">
                    <td class="order-item-fullfilled right">
                        ${orderItem?.quantityShipped}
                    </td>
                    <td class="order-item-received right">
                        ${orderItem?.quantityReceived}
                    </td>
                    <td class="right">
                        ${orderItem?.quantityInvoicedInStandardUom}
                    </td>
                    <td class="">
                        <g:formatNumber number="${orderItem?.unitPrice?:0}" />
                        ${orderInstance?.currencyCode?:grailsApplication.config.openboxes.locale.defaultCurrencyCode}
                    </td>
                    <td class="">
                        <g:formatNumber number="${orderItem?.totalPrice()?:0}" />
                        ${orderInstance?.currencyCode?:grailsApplication.config.openboxes.locale.defaultCurrencyCode}
                    </td>
                </g:if>
                <g:elseif test="${orderInstance.orderType==OrderType.findByCode(Constants.PUTAWAY_ORDER)}">
                    <td>
                        ${orderItem?.inventoryItem?.lotNumber}
                    </td>
                    <td>
                        <g:formatDate date="${orderItem?.inventoryItem?.expirationDate}" format="MM/dd/yyyy"/>
                    </td>
                    <td>
                        ${orderItem?.originBinLocation}
                    </td>
                    <td>
                        ${orderItem?.destinationBinLocation}
                    </td>
                </g:elseif>
            </tr>
        </g:each>
        </tbody>
        <g:if test="${orderInstance.orderType==OrderType.findByCode(OrderTypeCode.PURCHASE_ORDER.name())}">
            <tfoot>
            <tr class="">
                <th colspan="9" class="right">
                </th>
                <th colspan="1" class="left">
                    <g:formatNumber number="${orderInstance?.totalPrice()?:0.0 }"/>
                    ${orderInstance?.currencyCode?:grailsApplication.config.openboxes.locale.defaultCurrencyCode}
                </th>
            </tr>
            </tfoot>
        </g:if>

        </table>
    </g:if>
    <g:else>
        <div class="fade center empty"><warehouse:message code="default.noItems.label" /></div>
    </g:else>
</div>

