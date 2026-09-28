package com.example.saleslead.service;

import com.example.saleslead.dto.CustomerRequest;
import com.example.saleslead.entity.Customer;
import com.example.saleslead.exception.ResourceNotFoundException;
import com.example.saleslead.repository.CustomerRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CustomerService {

    private final CustomerRepository customerRepository;

    public CustomerService(CustomerRepository customerRepository) {
        this.customerRepository = customerRepository;
    }

    public List<Customer> getAllCustomers(String keyword) {

        if (keyword != null && !keyword.trim().isEmpty()) {
            return customerRepository.search(keyword.trim());
        }

        return customerRepository.findAll();
    }

    public Customer getCustomerById(Long id) {

        return customerRepository.findById(id)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Customer dengan ID " + id + " tidak ditemukan"
                        )
                );
    }

    public Customer createCustomer(CustomerRequest request) {

        String normalizedEmail =
                request.getEmail().trim().toLowerCase();

        if (customerRepository.existsByEmailIgnoreCase(normalizedEmail)) {
            throw new IllegalArgumentException(
                    "Email sudah digunakan customer lain"
            );
        }

        Customer customer = new Customer();

        customer.setFirstName(
                request.getFirstName().trim()
        );

        customer.setLastName(
                request.getLastName().trim()
        );

        customer.setEmail(normalizedEmail);

        customer.setCompany(
                request.getCompany() != null
                        ? request.getCompany().trim()
                        : null
        );

        return customerRepository.save(customer);
    }

    public Customer updateCustomer(
            Long id,
            CustomerRequest request
    ) {

        Customer customer = getCustomerById(id);

        String normalizedEmail =
                request.getEmail().trim().toLowerCase();

        customerRepository
                .findByEmailIgnoreCase(normalizedEmail)
                .ifPresent(existingCustomer -> {

                    if (!existingCustomer.getId().equals(id)) {
                        throw new IllegalArgumentException(
                                "Email sudah digunakan customer lain"
                        );
                    }

                });

        customer.setFirstName(
                request.getFirstName().trim()
        );

        customer.setLastName(
                request.getLastName().trim()
        );

        customer.setEmail(normalizedEmail);

        customer.setCompany(
                request.getCompany() != null
                        ? request.getCompany().trim()
                        : null
        );

        return customerRepository.save(customer);
    }

    public void deleteCustomer(Long id) {

        Customer customer = getCustomerById(id);

        customerRepository.delete(customer);
    }
}