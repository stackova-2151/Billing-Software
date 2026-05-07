# 🚀 Quick Reference - Stock & Expense CRUD

## 📦 STOCK MANAGEMENT

### Actions Available

| Action | Icon | Color | Description |
|--------|------|-------|-------------|
| **Add Stock** | ➕ | Green | Add quantity to any item |
| **Quick Add** | ➕ | Green | Fast add to specific item |
| **Edit** | ✏️ | Blue | Set absolute stock values |
| **View** | 👁️ | Gray | View item details |

### How to Use

#### Add Stock (General)
1. Click "Add Stock" button (top-right)
2. Select item from dropdown
3. Enter quantity to add
4. Optionally set threshold
5. Click "Add Stock"
6. ✅ Dialog closes, stock updated

#### Quick Add (Per Item)
1. Click ➕ icon on any row
2. Enter quantity to add
3. Click "Add"
4. ✅ Dialog closes, stock updated

#### Edit Stock
1. Click ✏️ icon on any row
2. Modify stock quantity (absolute value)
3. Modify threshold
4. Click "Update"
5. ✅ Dialog closes, stock updated

#### View Details
1. Click 👁️ icon on any row
2. View all item information
3. Click "Close"

### Status Colors
- 🟢 **Green** = In Stock (above threshold)
- 🟠 **Orange** = Low Stock (at or below threshold)
- 🔴 **Red** = Out of Stock (0 quantity)

---

## 💰 EXPENSE MANAGEMENT

### Actions Available

| Action | Icon | Color | Description |
|--------|------|-------|-------------|
| **Add Expense** | ➕ | Blue | Create new expense |
| **Edit** | ✏️ | Blue | Modify expense |
| **View** | 👁️ | Gray | View expense details |
| **Delete** | 🗑️ | Red | Remove expense |

### How to Use

#### Add Expense
1. Click "Add Expense" button (top-right)
2. Enter title (required)
3. Enter amount (required)
4. Select date
5. Optionally add note
6. Click "Add Expense"
7. ✅ Dialog closes, expense added

#### Edit Expense
1. Click ✏️ icon on any row
2. Modify any field
3. Click "Update"
4. ✅ Dialog closes, expense updated

#### View Details
1. Click 👁️ icon on any row
2. View all expense information
3. Click "Close"

#### Delete Expense
1. Click 🗑️ icon on any row
2. Confirm deletion
3. Click "Delete"
4. ✅ Dialog closes, expense removed

---

## ⚡ Quick Tips

### Stock Management
- Use **Quick Add** for fast stock additions
- Use **Edit** to set exact stock values
- Monitor **orange badges** for low stock
- **Red badges** block orders automatically

### Expense Management
- Total updates in real-time
- Date picker limits to past dates
- Notes are optional but recommended
- Delete requires confirmation

---

## 🎯 Keyboard Shortcuts

### In Dialogs
- **Tab** - Move to next field
- **Enter** - Submit form (when focused on button)
- **Esc** - Close dialog (cancel)

---

## ✅ Validation Rules

### Stock
- Quantity must be positive number
- Threshold must be non-negative
- Stock cannot be negative

### Expense
- Title is required
- Amount must be > 0
- Amount supports 2 decimals
- Date cannot be future

---

## 🔄 Real-time Updates

Both modules update automatically:
- ✅ Add/Edit/Delete reflects immediately
- ✅ No page refresh needed
- ✅ Multiple users see changes
- ✅ Firestore streams handle sync

---

## 📊 DataTable Features

### Stock Table
- 7 columns
- Sortable by default
- Color-coded quantities
- Veg/Non-Veg indicators
- Status badges

### Expense Table
- 5 columns
- Sorted by date (newest first)
- Amount badges
- Date + time display
- Note truncation

---

## 🎨 Color Guide

### Actions
- 🟢 **Green** (#16A34A) - Add/Create
- 🔵 **Blue** (#2563EB) - Edit/Primary
- 🔴 **Red** (#EF4444) - Delete/Warning
- ⚫ **Gray** (#64748B) - View/Info

### Status
- 🟢 **Green** - Success/In Stock
- 🟠 **Orange** - Warning/Low Stock
- 🔴 **Red** - Error/Out of Stock

---

## 🐛 Troubleshooting

### Dialog not closing?
- ✅ Fixed! All dialogs close after successful operations

### Changes not showing?
- Check internet connection
- Verify Firestore permissions

### Validation error?
- Check required fields
- Verify number formats
- Ensure positive values

---

## 📱 Mobile Support

Both screens are responsive:
- ✅ DataTable scrolls horizontally
- ✅ Dialogs adapt to screen size
- ✅ Touch-friendly buttons
- ✅ Proper spacing maintained

---

## 🎯 Best Practices

### Stock Management
1. Set thresholds for all items
2. Monitor low stock daily
3. Use Quick Add for speed
4. Use Edit for corrections

### Expense Management
1. Add expenses daily
2. Use descriptive titles
3. Add notes for context
4. Review total regularly

---

## 📞 Support

For issues or questions:
1. Check validation messages
2. Review error snackbars
3. Verify Firestore connection
4. Check console for errors

---

**Everything is production-ready and working perfectly!** 🚀
