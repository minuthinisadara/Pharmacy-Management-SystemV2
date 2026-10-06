package com.pharmacy.view;

import com.pharmacy.database.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import javax.swing.JOptionPane;
import javax.swing.table.DefaultTableModel;

public class POSForm extends javax.swing.JFrame {

    private static final java.util.logging.Logger logger = java.util.logging.Logger.getLogger(POSForm.class.getName());
    private DefaultTableModel cartModel;
    private double grandTotal = 0.0;
    
    // Default or passed session variables
    private int currentUserId = 1; 

    public POSForm() {
        initComponents();
        setLocationRelativeTo(null); // Center on screen
        initializeCartTable();
    }
    
    // Overloaded constructor if passing the logged-in user ID from the Login form
    public POSForm(int userId) {
        this.currentUserId = userId;
        initComponents();
        setLocationRelativeTo(null);
        initializeCartTable();
    }

    private void initializeCartTable() {
        cartModel = new DefaultTableModel(new String[]{"Product ID", "Product Name", "Unit Price (LKR)", "Qty", "Subtotal (LKR)"}, 0);
        tableCart.setModel(cartModel);
    }

    // 1. Add Product to Cart by ID or Name search
    private void addToCart() {
        String input = txtSearchProduct.getText().trim();
        String qtyStr = txtQuantity.getText().trim();

        if (input.isEmpty() || qtyStr.isEmpty()) {
            JOptionPane.showMessageDialog(this, "Please enter Product ID/Name and Quantity.", "Warning", JOptionPane.WARNING_MESSAGE);
            return;
        }

        int quantity;
        try {
            quantity = Integer.parseInt(qtyStr);
            if (quantity <= 0) {
                JOptionPane.showMessageDialog(this, "Quantity must be greater than zero.", "Error", JOptionPane.ERROR_MESSAGE);
                return;
            }
        } catch (NumberFormatException e) {
            JOptionPane.showMessageDialog(this, "Invalid quantity format.", "Error", JOptionPane.ERROR_MESSAGE);
            return;
        }

        String query = "SELECT product_id, product_name, unit_price, stock_quantity FROM products WHERE product_id = ? OR product_name LIKE ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setString(1, input);
            pstmt.setString(2, "%" + input + "%");
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                int prodId = rs.getInt("product_id");
                String prodName = rs.getString("product_name");
                double unitPrice = rs.getDouble("unit_price");
                int stock = rs.getInt("stock_quantity");

                if (quantity > stock) {
                    JOptionPane.showMessageDialog(this, "Insufficient stock! Only " + stock + " left.", "Stock Warning", JOptionPane.WARNING_MESSAGE);
                    return;
                }

                double subtotal = unitPrice * quantity;
                cartModel.addRow(new Object[]{prodId, prodName, unitPrice, quantity, subtotal});
                
                grandTotal += subtotal;
                lblGrandTotal.setText(String.format("Total: LKR %.2f", grandTotal));

                txtSearchProduct.setText("");
                txtQuantity.setText("");
            } else {
                JOptionPane.showMessageDialog(this, "Product not found.", "Not Found", JOptionPane.INFORMATION_MESSAGE);
            }

        } catch (SQLException e) {
            JOptionPane.showMessageDialog(this, "Database error: " + e.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
        }
    }

    // 2. Checkout & Process Transaction (Includes customer_id and user_id)
    private void processCheckout() {
        if (cartModel.getRowCount() == 0) {
            JOptionPane.showMessageDialog(this, "Cart is empty!", "Warning", JOptionPane.WARNING_MESSAGE);
            return;
        }

        // Get customer ID from text field (defaults to 1 if empty or invalid)
        int customerId = 1;
        String custIdStr = txtCustomerId.getText().trim();
        if (!custIdStr.isEmpty()) {
            try {
                customerId = Integer.parseInt(custIdStr);
            } catch (NumberFormatException e) {
                JOptionPane.showMessageDialog(this, "Invalid Customer ID format. Defaulting to Customer ID 1.", "Warning", JOptionPane.WARNING_MESSAGE);
            }
        }

        // Updated query including customer_id and user_id
        String insertInvoiceQuery = "INSERT INTO invoices (customer_id, user_id, total_amount, payment_method, transaction_date) VALUES (?, ?, ?, 'Cash', NOW())";
        String insertItemQuery = "INSERT INTO invoice_items (invoice_id, product_id, quantity_sold, unit_price_at_sale, subtotal) VALUES (?, ?, ?, ?, ?)";
        String updateStockQuery = "UPDATE products SET stock_quantity = stock_quantity - ? WHERE product_id = ?";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Start Transaction

            // Step A: Insert master record into invoices table
            PreparedStatement pstmtInvoice = conn.prepareStatement(insertInvoiceQuery, Statement.RETURN_GENERATED_KEYS);
            pstmtInvoice.setInt(1, customerId);
            pstmtInvoice.setInt(2, currentUserId);
            pstmtInvoice.setDouble(3, grandTotal);
            pstmtInvoice.executeUpdate();

            ResultSet generatedKeys = pstmtInvoice.getGeneratedKeys();
            int invoiceId = 0;
            if (generatedKeys.next()) {
                invoiceId = generatedKeys.getInt(1);
            }

            // Step B: Prepare batch statements for line items and stock reduction
            PreparedStatement pstmtItem = conn.prepareStatement(insertItemQuery);
            PreparedStatement pstmtStock = conn.prepareStatement(updateStockQuery);

            for (int i = 0; i < cartModel.getRowCount(); i++) {
                int prodId = (int) cartModel.getValueAt(i, 0);
                double unitPrice = (double) cartModel.getValueAt(i, 2);
                int qtySold = (int) cartModel.getValueAt(i, 3);
                double subtotal = (double) cartModel.getValueAt(i, 4);

                // Add item to invoice_items batch
                pstmtItem.setInt(1, invoiceId);
                pstmtItem.setInt(2, prodId);
                pstmtItem.setInt(3, qtySold);
                pstmtItem.setDouble(4, unitPrice);
                pstmtItem.setDouble(5, subtotal);
                pstmtItem.addBatch();

                // Add stock reduction to batch
                pstmtStock.setInt(1, qtySold);
                pstmtStock.setInt(2, prodId);
                pstmtStock.addBatch();
            }

            pstmtItem.executeBatch();
            pstmtStock.executeBatch();

            conn.commit(); // Commit all database changes securely
            JOptionPane.showMessageDialog(this, "Checkout Successful! Invoice ID: " + invoiceId, "Success", JOptionPane.INFORMATION_MESSAGE);

            // Reset Cart UI & Customer Field
            cartModel.setRowCount(0);
            grandTotal = 0.0;
            lblGrandTotal.setText("Total: LKR 0.00");
            txtCustomerId.setText("1");

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { logger.log(java.util.logging.Level.SEVERE, null, ex); }
            }
            JOptionPane.showMessageDialog(this, "Checkout failed: " + e.getMessage(), "Database Error", JOptionPane.ERROR_MESSAGE);
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { logger.log(java.util.logging.Level.SEVERE, null, ex); }
            }
        }
    }

    @SuppressWarnings("unchecked")
    private void initComponents() {

        jPanel1 = new javax.swing.JPanel();
        jLabel1 = new javax.swing.JLabel();
        jLabel4 = new javax.swing.JLabel();
        txtCustomerId = new javax.swing.JTextField();
        jLabel2 = new javax.swing.JLabel();
        txtSearchProduct = new javax.swing.JTextField();
        jLabel3 = new javax.swing.JLabel();
        txtQuantity = new javax.swing.JTextField();
        btnAddToCart = new javax.swing.JButton();
        jScrollPane1 = new javax.swing.JScrollPane();
        tableCart = new javax.swing.JTable();
        lblGrandTotal = new javax.swing.JLabel();
        btnCheckout = new javax.swing.JButton();
        btnLogout = new javax.swing.JButton();

        setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);
        setTitle("Cashier POS Billing Terminal");
        getContentPane().setLayout(new org.netbeans.lib.awtextra.AbsoluteLayout());

        jPanel1.setBackground(new java.awt.Color(24, 24, 115));
        jPanel1.setLayout(new org.netbeans.lib.awtextra.AbsoluteLayout());

        jLabel1.setFont(new java.awt.Font("Segoe UI", 1, 22)); // NOI18N
        jLabel1.setForeground(new java.awt.Color(255, 255, 255));
        jLabel1.setText("Cashier Billing Terminal");
        jPanel1.add(jLabel1, new org.netbeans.lib.awtextra.AbsoluteConstraints(30, 20, -1, -1));

        jLabel4.setFont(new java.awt.Font("Segoe UI", 1, 14)); // NOI18N
        jLabel4.setForeground(new java.awt.Color(255, 255, 255));
        jLabel4.setText("Customer ID:");
        jPanel1.add(jLabel4, new org.netbeans.lib.awtextra.AbsoluteConstraints(30, 70, -1, -1));

        txtCustomerId.setFont(new java.awt.Font("Segoe UI", 0, 14)); // NOI18N
        txtCustomerId.setText("1"); // Default walk-in customer ID
        jPanel1.add(txtCustomerId, new org.netbeans.lib.awtextra.AbsoluteConstraints(30, 100, 100, 35));

        jLabel2.setFont(new java.awt.Font("Segoe UI", 1, 14)); // NOI18N
        jLabel2.setForeground(new java.awt.Color(255, 255, 255));
        jLabel2.setText("Product ID / Name:");
        jPanel1.add(jLabel2, new org.netbeans.lib.awtextra.AbsoluteConstraints(150, 70, -1, -1));

        txtSearchProduct.setFont(new java.awt.Font("Segoe UI", 0, 14)); // NOI18N
        jPanel1.add(txtSearchProduct, new org.netbeans.lib.awtextra.AbsoluteConstraints(150, 100, 200, 35));

        jLabel3.setFont(new java.awt.Font("Segoe UI", 1, 14)); // NOI18N
        jLabel3.setForeground(new java.awt.Color(255, 255, 255));
        jLabel3.setText("Quantity:");
        jPanel1.add(jLabel3, new org.netbeans.lib.awtextra.AbsoluteConstraints(370, 70, -1, -1));

        txtQuantity.setFont(new java.awt.Font("Segoe UI", 0, 14)); // NOI18N
        jPanel1.add(txtQuantity, new org.netbeans.lib.awtextra.AbsoluteConstraints(370, 100, 80, 35));

        btnAddToCart.setFont(new java.awt.Font("Segoe UI", 1, 14)); // NOI18N
        btnAddToCart.setText("Add to Cart");
        btnAddToCart.addActionListener(evt -> addToCart());
        jPanel1.add(btnAddToCart, new org.netbeans.lib.awtextra.AbsoluteConstraints(470, 100, 130, 35));

        tableCart.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {},
            new String [] {"Product ID", "Product Name", "Unit Price (LKR)", "Qty", "Subtotal (LKR)"}
        ));
        jScrollPane1.setViewportView(tableCart);

        jPanel1.add(jScrollPane1, new org.netbeans.lib.awtextra.AbsoluteConstraints(30, 150, 570, 220));

        lblGrandTotal.setFont(new java.awt.Font("Segoe UI", 1, 20)); // NOI18N
        lblGrandTotal.setForeground(new java.awt.Color(0, 255, 128));
        lblGrandTotal.setText("Total: LKR 0.00");
        jPanel1.add(lblGrandTotal, new org.netbeans.lib.awtextra.AbsoluteConstraints(30, 390, -1, -1));

        btnCheckout.setBackground(new java.awt.Color(0, 153, 76));
        btnCheckout.setFont(new java.awt.Font("Segoe UI", 1, 14)); // NOI18N
        btnCheckout.setForeground(new java.awt.Color(255, 255, 255));
        btnCheckout.setText("Complete Payment");
        btnCheckout.addActionListener(evt -> processCheckout());
        jPanel1.add(btnCheckout, new org.netbeans.lib.awtextra.AbsoluteConstraints(410, 390, 190, 40));

        btnLogout.setFont(new java.awt.Font("Segoe UI", 1, 14)); // NOI18N
        btnLogout.setForeground(new java.awt.Color(204, 0, 0));
        btnLogout.setText("Logout");
        btnLogout.addActionListener(evt -> {
            this.dispose();
            new LoginForm().setVisible(true);
        });
        jPanel1.add(btnLogout, new org.netbeans.lib.awtextra.AbsoluteConstraints(480, 20, 120, 35));

        getContentPane().add(jPanel1, new org.netbeans.lib.awtextra.AbsoluteConstraints(0, 0, 630, 460));

        pack();
    }

    public static void main(String args[]) {
        java.awt.EventQueue.invokeLater(() -> new POSForm().setVisible(true));
    }

    // Variables declaration - do not modify
    private javax.swing.JButton btnAddToCart;
    private javax.swing.JButton btnCheckout;
    private javax.swing.JButton btnLogout;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JLabel jLabel2;
    private javax.swing.JLabel jLabel3;
    private javax.swing.JLabel jLabel4;
    private javax.swing.JPanel jPanel1;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JLabel lblGrandTotal;
    private javax.swing.JTable tableCart;
    private javax.swing.JTextField txtCustomerId;
    private javax.swing.JTextField txtQuantity;
    private javax.swing.JTextField txtSearchProduct;
    // End of variables declaration
}