package com.app.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.app.entity.User;

public interface UserRepository extends JpaRepository<User,Long> {
	User findByUsername(String username);
	// Fetch only users for the current company
    List<User> findByTenantId(Long tenantId);

}
