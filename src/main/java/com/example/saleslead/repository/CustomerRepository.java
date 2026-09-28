package com.example.saleslead.repository;

import com.example.saleslead.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface CustomerRepository extends JpaRepository<Customer, Long> {

    boolean existsByEmailIgnoreCase(String email);

    Optional<Customer> findByEmailIgnoreCase(String email);

    @Query("""
        SELECT c FROM Customer c
        WHERE LOWER(c.firstName) LIKE LOWER(CONCAT('%', :keyword, '%'))
           OR LOWER(c.lastName) LIKE LOWER(CONCAT('%', :keyword, '%'))
           OR LOWER(CONCAT(c.firstName, ' ', c.lastName)) LIKE LOWER(CONCAT('%', :keyword, '%'))
           OR LOWER(CONCAT(c.lastName, ' ', c.firstName)) LIKE LOWER(CONCAT('%', :keyword, '%'))
           OR LOWER(c.email) LIKE LOWER(CONCAT('%', :keyword, '%'))
           OR (c.company IS NOT NULL AND LOWER(c.company) LIKE LOWER(CONCAT('%', :keyword, '%')))
        ORDER BY c.id DESC
    """)
    List<Customer> search(@Param("keyword") String keyword);
}