package org.hylly.mtk2garmin;

class LightRelationMember {
    private final long id;
    private final String role;

    public LightRelationMember(long id, String role) {
        this.id = id;
        this.role = role;
    }

    long getId() {
        return id;
    }

    String getRole() {
        return role;
    }

}
