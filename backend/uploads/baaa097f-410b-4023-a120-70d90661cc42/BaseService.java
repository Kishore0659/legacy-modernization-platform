package com.modernize.core;

public abstract class BaseService {
    protected String serviceId;

    public void logAudit(String event) {
        System.out.println("Audit Event Recorded: " + event);
    }
}
