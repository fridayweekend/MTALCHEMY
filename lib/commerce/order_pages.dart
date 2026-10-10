import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../shared/file_export.dart';
import '../shared/auth_prototype_store.dart';
import '../shared/portal_components.dart';
import '../shared/report_document.dart';
import '../theme.dart';
import '../widgets.dart';
import 'commerce_prototype_store.dart';
import 'store_pages.dart';

final _store = CommercePrototypeStore.instance;

class CartPage extends StatelessWidget {
  const CartPage({super.key});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _store,
    builder: (context, _) => PortalPage(
      title: 'Your shopping cart.',
      eyebrow: 'Cart',
      children: [
        if (_store.cartLines.isEmpty)
          InfoCard(
            child: Column(
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  color: purple,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text('Your cart is empty.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => go(context, '/store'),
                  child: const Text('Continue shopping'),
                ),
              ],
            ),
          )
        else ...[
          for (final line in _store.cartLines) _CartLineCard(line: line),
          const SizedBox(height: 18),
          _TotalsCard(
            subtotal: _store.subtotal,
            shipping: _store.shipping,
            total: _store.total,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              OutlinedButton(
                onPressed: () => go(context, '/store'),
                child: const Text('Continue shopping'),
              ),
              FilledButton.icon(
                onPressed: () => go(context, '/checkout'),
                icon: const Icon(Icons.lock_outline),
                label: const Text('Proceed to Checkout'),
              ),
              OutlinedButton.icon(
                onPressed: () => go(context, '/quote-request'),
                icon: const Icon(Icons.request_quote_outlined),
                label: const Text('Request a business quote'),
              ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        portalLinks(context),
      ],
    ),
  );
}

class _CartLineCard extends StatelessWidget {
  const _CartLineCard({required this.line});
  final CartLine line;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 680;
        final product = Row(
          children: [
            SizedBox(
              width: narrow ? 72 : 92,
              child: ProductArtwork(product: line.product, height: 78),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.product.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    line.product.digital
                        ? 'Digital · no stock or shipping'
                        : 'Physical · stock tracked, delivery required',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Text(money(line.product.price)),
                ],
              ),
            ),
          ],
        );
        final controls = Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 2,
          children: [
            IconButton(
              tooltip: 'Decrease quantity',
              onPressed: () =>
                  _store.setQuantity(line.product.id, line.quantity - 1),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text(
              '${line.quantity}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            IconButton(
              tooltip: 'Increase quantity',
              onPressed:
                  line.product.digital || line.quantity < line.product.stock
                  ? () => _store.addToCart(line.product.id)
                  : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
            const SizedBox(width: 8),
            Text(
              money(line.subtotal),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            IconButton(
              tooltip: 'Remove ${line.product.name}',
              onPressed: () => _store.removeFromCart(line.product.id),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        );
        return InfoCard(
          padding: 16,
          child: narrow
              ? Column(children: [product, const SizedBox(height: 8), controls])
              : Row(
                  children: [
                    Expanded(child: product),
                    controls,
                  ],
                ),
        );
      },
    ),
  );
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({
    required this.subtotal,
    required this.shipping,
    required this.total,
  });
  final double subtotal;
  final double shipping;
  final double total;
  @override
  Widget build(BuildContext context) => InfoCard(
    color: const Color(0xFFFFF8DE),
    child: Column(
      children: [
        _TotalLine(label: 'Subtotal', value: money(subtotal)),
        _TotalLine(label: 'Discount', value: money(0)),
        _TotalLine(
          label: 'Shipping',
          value: shipping == 0
              ? 'Digital order / no shipping'
              : money(shipping),
        ),
        const Divider(height: 24),
        _TotalLine(label: 'Total', value: money(total), strong: true),
      ],
    ),
  );
}

class _TotalLine extends StatelessWidget {
  const _TotalLine({
    required this.label,
    required this.value,
    this.strong = false,
  });
  final String label;
  final String value;
  final bool strong;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: strong ? FontWeight.w900 : FontWeight.w500,
            fontSize: strong ? 19 : null,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: strong ? FontWeight.w900 : FontWeight.w600,
            fontSize: strong ? 19 : null,
          ),
        ),
      ],
    ),
  );
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController(
    text: AuthPrototypeStore.instance.email ?? '',
  );
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _postcode = TextEditingController();
  final _country = TextEditingController(text: 'Malaysia');
  final _shippingAddress = TextEditingController();
  final _shippingCity = TextEditingController();
  final _shippingState = TextEditingController();
  final _shippingPostcode = TextEditingController();
  final _shippingCountry = TextEditingController(text: 'Malaysia');
  bool _shipToDifferentAddress = false;
  String paymentMethod = 'Card';
  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    _city.dispose();
    _state.dispose();
    _postcode.dispose();
    _country.dispose();
    _shippingAddress.dispose();
    _shippingCity.dispose();
    _shippingState.dispose();
    _shippingPostcode.dispose();
    _shippingCountry.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _store,
    builder: (context, _) => PortalPage(
      title: 'A few details, then you’re set.',
      eyebrow: 'Secure checkout',
      children: [
        if (_store.cartLines.isEmpty)
          InfoCard(
            child: Column(
              children: [
                const Text('Your cart is empty.'),
                TextButton(
                  onPressed: () => go(context, '/store'),
                  child: const Text('Return to store'),
                ),
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (context, box) {
              final form = InfoCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Customer information',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Account email',
                          helperText:
                              'This order is linked to your signed-in account.',
                        ),
                        validator: (v) =>
                            v == null ||
                                !RegExp(
                                  r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                ).hasMatch(v.trim())
                            ? 'Enter a valid email'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Phone'),
                        validator: _required,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Billing address',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _address,
                        decoration: const InputDecoration(
                          labelText: 'Street address',
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 12),
                      _responsiveFieldPair(
                        TextFormField(
                          controller: _city,
                          decoration: const InputDecoration(labelText: 'City'),
                          validator: _required,
                        ),
                        TextFormField(
                          controller: _state,
                          decoration: const InputDecoration(labelText: 'State'),
                          validator: _required,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _responsiveFieldPair(
                        TextFormField(
                          controller: _postcode,
                          decoration: const InputDecoration(
                            labelText: 'Postcode',
                          ),
                          validator: _required,
                        ),
                        TextFormField(
                          controller: _country,
                          decoration: const InputDecoration(
                            labelText: 'Country',
                          ),
                          validator: _required,
                        ),
                      ),
                      if (_store.cartHasPhysical) ...[
                        const SizedBox(height: 18),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          value: _shipToDifferentAddress,
                          onChanged: (value) =>
                              setState(() => _shipToDifferentAddress = value),
                          title: const Text('Ship to a different address'),
                        ),
                        if (_shipToDifferentAddress) ...[
                          Text(
                            'Shipping address',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _shippingAddress,
                            decoration: const InputDecoration(
                              labelText: 'Street address',
                            ),
                            validator: _required,
                          ),
                          const SizedBox(height: 12),
                          _responsiveFieldPair(
                            TextFormField(
                              controller: _shippingCity,
                              decoration: const InputDecoration(
                                labelText: 'City',
                              ),
                              validator: _required,
                            ),
                            TextFormField(
                              controller: _shippingState,
                              decoration: const InputDecoration(
                                labelText: 'State',
                              ),
                              validator: _required,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _responsiveFieldPair(
                            TextFormField(
                              controller: _shippingPostcode,
                              decoration: const InputDecoration(
                                labelText: 'Postcode',
                              ),
                              validator: _required,
                            ),
                            TextFormField(
                              controller: _shippingCountry,
                              decoration: const InputDecoration(
                                labelText: 'Country',
                              ),
                              validator: _required,
                            ),
                          ),
                        ],
                      ],
                      const SizedBox(height: 24),
                      Text(
                        'Payment gateway',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: paymentMethod,
                        items: const [
                          DropdownMenuItem(
                            value: 'Card',
                            child: Text('Credit / debit card · demo only'),
                          ),
                          DropdownMenuItem(
                            value: 'FPX',
                            child: Text('Online banking (FPX) · demo only'),
                          ),
                          DropdownMenuItem(
                            value: 'Wallet',
                            child: Text('E-wallet · demo only'),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => paymentMethod = value ?? 'Card'),
                      ),
                      const SizedBox(height: 10),
                      const InfoCard(
                        color: Color(0xFFFFF8DE),
                        child: Text(
                          'Payment provider not connected. This prototype will not collect card details or charge you. Orders stay Pending until an admin manually updates the status. Configure a secure server-side gateway before accepting real payments.',
                          style: TextStyle(height: 1.45),
                        ),
                      ),
                    ],
                  ),
                ),
              );
              final summary = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order summary',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 14),
                        for (final line in _store.cartLines)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${line.product.name} × ${line.quantity}',
                                  ),
                                ),
                                Text(money(line.subtotal)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _TotalsCard(
                    subtotal: _store.subtotal,
                    shipping: _store.shipping,
                    total: _store.total,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _placeOrder,
                    child: const Text('Place order · payment stays pending'),
                  ),
                ],
              );
              return box.maxWidth > 850
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: form),
                        const SizedBox(width: 22),
                        Expanded(flex: 2, child: summary),
                      ],
                    )
                  : Column(
                      children: [form, const SizedBox(height: 20), summary],
                    );
            },
          ),
      ],
    ),
  );
  void _placeOrder() {
    if (!_formKey.currentState!.validate()) return;
    final order = _store.placeOrder(
      customerName: _name.text.trim(),
      customerEmail: _email.text.trim(),
      customerPhone: _phone.text.trim(),
      billingAddress:
          '${_address.text.trim()}, ${_city.text.trim()}, ${_state.text.trim()} ${_postcode.text.trim()}, ${_country.text.trim()}',
      address: _store.cartHasPhysical
          ? _shipToDifferentAddress
                ? '${_shippingAddress.text.trim()}, ${_shippingCity.text.trim()}, ${_shippingState.text.trim()} ${_shippingPostcode.text.trim()}, ${_shippingCountry.text.trim()}'
                : '${_address.text.trim()}, ${_city.text.trim()}, ${_state.text.trim()} ${_postcode.text.trim()}, ${_country.text.trim()}'
          : '',
      paymentMethod: paymentMethod,
    );
    if (order != null && mounted) {
      Navigator.pushNamed(
        context,
        '/order-confirmation',
        arguments: order.number,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your cart changed. Review the available items and try again.',
          ),
        ),
      );
    }
  }
}

class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({
    super.key,
    this.orderNumber,
    this.confirmation = true,
  });
  final String? orderNumber;
  final bool confirmation;
  @override
  Widget build(BuildContext context) {
    final currentEmail = AuthPrototypeStore.instance.email;
    final candidate = _store.orderByNumber(orderNumber);
    final order =
        candidate?.customerEmail.toLowerCase() == currentEmail?.toLowerCase()
        ? candidate
        : null;
    return PortalPage(
      title: confirmation ? 'Thank you for your order.' : 'Order details.',
      eyebrow: confirmation ? 'Order confirmation' : 'My Orders',
      children: [
        InfoCard(
          color: const Color(0xFFFFF8DE),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                order?.paymentStatus == 'Paid'
                    ? Icons.check_circle_outline
                    : Icons.hourglass_top_rounded,
                color: order?.paymentStatus == 'Paid'
                    ? Colors.green
                    : Colors.orange.shade800,
                size: 44,
              ),
              const SizedBox(height: 12),
              if (order == null)
                const Text('Order details are not available in this prototype.')
              else ...[
                Text(
                  'Order ${order.number}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Payment: ${order.paymentMethod} · Status: ${order.paymentStatus} · Order: ${order.fulfilmentStatus}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Customer: ${order.customerName} · ${order.customerEmail} · ${order.customerPhone}',
                ),
                if (order.billingAddress != null)
                  Text('Billing: ${order.billingAddress}'),
                if (!order.hasPhysical)
                  const Text('Shipping: not required for digital items.'),
                const SizedBox(height: 16),
                for (final line in order.lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${line.product.name} × ${line.quantity}',
                          ),
                        ),
                        Text(money(line.subtotal)),
                      ],
                    ),
                  ),
                const Divider(),
                _TotalLine(
                  label: 'Order total',
                  value: money(order.total),
                  strong: true,
                ),
                if (order.shippingAddress != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text('Shipping to: ${order.shippingAddress}'),
                  ),
                if (order.trackingNumber != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: SelectableText(
                      'Tracking number: ${order.trackingNumber}',
                    ),
                  ),
                if (order.hasDigital && order.paymentStatus == 'Paid')
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: FilledButton.icon(
                      onPressed: () => go(context, '/digital-library'),
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('Open Digital Product Library'),
                    ),
                  ),
                if (order.hasDigital && order.paymentStatus != 'Paid')
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'Digital downloads unlock after payment is confirmed. This prototype order is still pending.',
                    ),
                  ),
                if (order.hasPhysical)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      order.trackingNumber == null
                          ? 'Physical item status: ${order.fulfilmentStatus}. Tracking appears after admin marks it Shipped.'
                          : 'Physical item status: ${order.fulfilmentStatus} · Tracking ${order.trackingNumber}',
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: OutlinedButton.icon(
                    onPressed: () => _downloadInvoice(context, order),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Download bill / invoice PDF'),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                children: [
                  OutlinedButton(
                    onPressed: () => go(context, '/orders'),
                    child: const Text('My Orders'),
                  ),
                  FilledButton(
                    onPressed: () => go(context, '/store'),
                    child: const Text('Continue shopping'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _responsiveFieldPair(Widget first, Widget second) => LayoutBuilder(
  builder: (context, constraints) => constraints.maxWidth < 440
      ? Column(children: [first, const SizedBox(height: 12), second])
      : Row(
          children: [
            Expanded(child: first),
            const SizedBox(width: 12),
            Expanded(child: second),
          ],
        ),
);

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _store,
    builder: (context, _) {
      final orders = _store.ordersFor(AuthPrototypeStore.instance.email ?? '');
      return PortalPage(
        title: 'Your purchases in one place.',
        eyebrow: 'My Orders',
        children: [
          if (orders.isEmpty)
            const InfoCard(child: Text('You have not placed any orders yet.'))
          else
            for (final order in orders)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InfoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () => go(
                              context,
                              '/order-details',
                              arguments: order.number,
                            ),
                            icon: const Icon(Icons.receipt_long_outlined),
                            label: Text(order.number),
                          ),
                          Text(
                            money(order.total),
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${order.date.day}/${order.date.month}/${order.date.year} · ${order.paymentStatus} · ${order.fulfilmentStatus}',
                      ),
                      if (order.trackingNumber != null)
                        Text('Tracking: ${order.trackingNumber}'),
                      if (order.billingAddress != null)
                        Text('Bill to: ${order.billingAddress}'),
                      if (order.hasPhysical)
                        Text(
                          order.shippingAddress == null
                              ? 'Ship to: address not recorded'
                              : 'Ship to: ${order.shippingAddress}',
                        ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _downloadInvoice(context, order),
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('Download bill / invoice'),
                      ),
                      for (final line in order.lines)
                        Text('${line.product.name} × ${line.quantity}'),
                      if (order.hasDigital)
                        TextButton.icon(
                          onPressed: () => go(context, '/digital-library'),
                          icon: const Icon(Icons.download_outlined),
                          label: const Text('Open digital products'),
                        ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => go(context, '/store'),
            child: const Text('Continue shopping'),
          ),
        ],
      );
    },
  );
}

Future<void> _downloadInvoice(BuildContext context, ShopOrder order) async {
  final subtotal = order.lines.fold<double>(
    0,
    (sum, line) => sum + line.subtotal,
  );
  final shipping = order.total - subtotal;
  final lines = <String>[
    'MT ALCHEMY - ORDER BILL / PROTOTYPE INVOICE',
    'Order: ${order.number}',
    'Date: ${order.date.day}/${order.date.month}/${order.date.year}',
    'Customer: ${order.customerName}',
    'Email: ${order.customerEmail}',
    'Phone: ${order.customerPhone}',
    'Bill to: ${order.billingAddress ?? 'Not provided'}',
    if (order.hasPhysical)
      'Ship to: ${order.shippingAddress ?? 'Not provided'}',
    'Payment: ${order.paymentMethod} / ${order.paymentStatus}',
    'Fulfilment: ${order.fulfilmentStatus}',
    if (order.trackingNumber != null) 'Tracking: ${order.trackingNumber}',
    'Items:',
    for (final line in order.lines)
      '${line.product.name} x ${line.quantity} @ RM ${line.product.price.toStringAsFixed(2)} = RM ${line.subtotal.toStringAsFixed(2)}',
    'Subtotal: RM ${subtotal.toStringAsFixed(2)}',
    'Shipping: ${order.hasPhysical ? 'RM ${shipping.toStringAsFixed(2)}' : 'Not applicable (digital order)'}',
    'Total: RM ${order.total.toStringAsFixed(2)}',
    'Prototype document only. Payment provider and tax invoice issuance are not configured.',
  ];
  final path = await saveLocalFile(
    'invoice-${order.number}.pdf',
    createReportPdf(lines),
  );
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        path == null
            ? 'PDF saving is unavailable on this platform.'
            : 'Bill saved to $path',
      ),
    ),
  );
}

class DigitalProductLibraryPage extends StatelessWidget {
  const DigitalProductLibraryPage({super.key});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _store,
    builder: (context, _) {
      final orders = _store.digitalOrdersFor(
        AuthPrototypeStore.instance.email ?? '',
      );
      return PortalPage(
        title: 'Your learning resources.',
        eyebrow: 'Digital Product Library',
        children: [
          const InfoCard(
            color: Color(0xFFFFF8DE),
            child: Text(
              'Downloads appear after a digital item has been purchased. This prototype checks the local order list; the final app must verify access against the signed-in user account.',
              style: TextStyle(height: 1.5),
            ),
          ),
          const SizedBox(height: 20),
          if (orders.isEmpty)
            const InfoCard(
              child: Text(
                'No paid digital products are available yet. Complete a purchase and confirm payment to unlock your downloads.',
              ),
            )
          else
            for (final order in orders)
              for (final line in order.lines.where(
                (line) => line.product.digital,
              ))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InfoCard(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final resourceInfo = Row(
                          children: [
                            const Icon(
                              Icons.menu_book_outlined,
                              color: purple,
                              size: 34,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    line.product.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  Text(
                                    'Purchased with order ${order.number} · ${order.date.day}/${order.date.month}/${order.date.year}',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                        final download = FilledButton.icon(
                          onPressed: line.product.downloadAssetPath == null
                              ? null
                              : () => _downloadDigitalResource(
                                  context,
                                  line.product,
                                ),
                          icon: const Icon(Icons.download_outlined),
                          label: const Text('Download resource'),
                        );
                        return constraints.maxWidth < 600
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  resourceInfo,
                                  const SizedBox(height: 14),
                                  download,
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(child: resourceInfo),
                                  const SizedBox(width: 16),
                                  download,
                                ],
                              );
                      },
                    ),
                  ),
                ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => go(context, '/orders'),
            child: const Text('View My Orders'),
          ),
        ],
      );
    },
  );
}

Future<void> _downloadDigitalResource(
  BuildContext context,
  ShopProduct product,
) async {
  final assetPath = product.downloadAssetPath;
  if (assetPath == null) return;
  try {
    final content = await rootBundle.loadString(assetPath);
    final safeName = product.name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    final path = await saveLocalFile('$safeName.txt', utf8.encode(content));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          path == null
              ? 'File saving is unavailable on this platform.'
              : 'Resource saved to $path',
        ),
      ),
    );
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save this resource: $error')),
      );
    }
  }
}
