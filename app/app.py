import streamlit as st
import pay
import profile
import signup
import profile2

tier_charges = [5, 4, 3, 2, 1]
user_tier = 0

st.markdown(
    """
<style>
.standard-text {
    font-size:50px;
}
</style>
""",
    unsafe_allow_html=True,
)


# https://medium.com/@u.praneel.nihar/building-multi-page-web-app-using-streamlit-7a40d55fa5b4

st.image("image/logo.png", width=1, use_column_width=True)
st.title("Money that cares.")
st.markdown("""---""")


PAGES = {"Signup": signup, "Pay an account": pay, "View Wallet": profile2}
st.sidebar.title("Navigation")
selection = st.sidebar.radio("Go to", list(PAGES.keys()))
page = PAGES[selection]
user_tier = page.app(user_tier, tier_charges)
