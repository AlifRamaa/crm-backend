package com.example.saleslead.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class CustomerRequest {

    @NotBlank(message = "First name wajib diisi")
    @Size(max = 100, message = "First name maksimal 100 karakter")
    private String firstName;

    @NotBlank(message = "Last name wajib diisi")
    @Size(max = 100, message = "Last name maksimal 100 karakter")
    private String lastName;

    @NotBlank(message = "Email wajib diisi")
    @Email(message = "Format email tidak valid")
    private String email;

    @Size(max = 150, message = "Company maksimal 150 karakter")
    private String company;

    public CustomerRequest() {
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getCompany() {
        return company;
    }

    public void setCompany(String company) {
        this.company = company;
    }
}