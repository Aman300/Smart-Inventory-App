const mongoose = require('mongoose');

const productSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Please enter product title'],
      trim: true,
    },
    description: {
      type: String,
      required: [true, 'Please enter product description'],
      trim: true,
    },
    price: {
      type: Number,
      required: [true, 'Please enter product price'],
      min: [0, 'Price cannot be negative'],
    },
    quantity: {
      type: Number,
      required: [true, 'Please enter product quantity'],
      min: [0, 'Quantity cannot be negative'],
      default: 0,
    },
    category: {
      type: String,
      required: [true, 'Please enter product category'],
      trim: true,
    },
    image: {
      type: String,
      default: '',
    },
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
  },
  {
    timestamps: true,
  }
);

const Product = mongoose.model('Product', productSchema);
module.exports = Product;
