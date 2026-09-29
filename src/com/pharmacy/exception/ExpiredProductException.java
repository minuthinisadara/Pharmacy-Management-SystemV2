package com.pharmacy.exception;

public class ExpiredProductException extends Exception {
    public ExpiredProductException(String message) {
        super(message);
    }
}